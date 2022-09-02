//
//  ContecSDK.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 24.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation
import CoreBluetooth


enum FailCodes {
    case bluetoothIsOff
    case periferalIsNotFromThisQueue
    case failedToDiscoverServiceError
    case periferalIsNotReady
}

enum SuccessCodes {
    case disconnected
    case gotData
    case connected
}


/// Contec device UUIDs for using with GATT services and characteristic
struct ContecUUIDs {
    public static let mainService = CBUUID.init(string: "0000ff12-0000-1000-8000-00805f9b34fb")
    
    public static let sendDataCharacteristic = CBUUID.init(string: "0000ff01-0000-1000-8000-00805f9b34fb")
    public static let getDataCharacteristic = CBUUID.init(string: "0000ff02-0000-1000-8000-00805f9b34fb")
}


class ContecSDK: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    private let onSuccessCallback: (_ successCode: SuccessCodes) -> Void
    
    /// Callback for discovered devices after call ``discover()``
    private let onDiscoverCallback: (_ peripheral: CBPeripheral, _ advertisementData: [String : Any], _ RSSI: NSNumber) -> Void
    
    private let onFailCallback: (_ failCode: FailCodes) -> Void
    
    /// from 0 to 1.0
    private let onProgressUpdate: (_ progress: Float) -> Void
    
    private var centralManager: CBCentralManager?
    private var isCentralManagerReady: Bool = false
    
    private var peripheral: CBPeripheral!
    private var isPeriferalReady: Bool = false
    
    private var sendDataCharacteristic: CBCharacteristic?
    private var getDataCharacteristic: CBCharacteristic?
    
    private var contecDeviceController: ContecDeviceController?
    
    private let dataSerializer = DataSerializer()
    
    public var resultDataController: ResultDataController?
    
    init (onSuccessCallback: @escaping (_ successCode: SuccessCodes) -> Void, onDiscoverCallback: @escaping (_ peripheral: CBPeripheral, _ advertisementData: [String : Any], _ RSSI: NSNumber) -> Void, onFailCallback: @escaping (_ failCode: FailCodes) -> Void, onProgressUpdate: @escaping (_ progress: Float) -> Void) {
        self.onSuccessCallback = onSuccessCallback
        self.onDiscoverCallback = onDiscoverCallback
        self.onFailCallback = onFailCallback
        self.onProgressUpdate = onProgressUpdate
    }
    
    // MARK: - public methods
    
    /// Request to load data from contec device
    public func getData() {
        if isPeriferalReady {
            sendData(dataSerializer.getDataRequest())
        } else {
            onFailCallback(.periferalIsNotReady)
        }
    }
    
    public func deleteData() {
        if isPeriferalReady {
            sendData(dataSerializer.generateDataForDelete())
        } else {
            onFailCallback(.periferalIsNotReady)
        }
    }
    
    public func setUserParams() {
        // TODO
    }
    
    /// Start BLE devices discovering
    ///
    /// Discovered devices with type ``CBPeripheral`` will be go
    /// to `onDiscoverCallback` mentioned in ``init(onSuccessCallback:onDiscoverCallback:onFailCallback:)``
    public func discover() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /// Step BLE devices discovering
    public func stopDiscover() {
        if isCentralManagerReady {
            centralManager!.stopScan()
        } else {
            onFailCallback(FailCodes.bluetoothIsOff)
        }
    }
    
    /// Connect to suggested peripheral
    /// - Parameter peripheral: BLE devices from discovered device callback
    public func connect(_ peripheral: CBPeripheral) {
        if isCentralManagerReady {
            centralManager!.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
            centralManager!.connect(self.peripheral, options: nil)
            contecDeviceController = ContecDeviceController(writeValueCallback: sendData, saveResultDataCallback: saveResultData, onProgressUpdate: onProgressUpdate)
        } else {
            onFailCallback(FailCodes.bluetoothIsOff)
        }
    }
    
    // MARK: - private functions for ``ContecDevice`` usage
    
    private func sendData(_ data: Data) {
        peripheral.writeValue(data, for: sendDataCharacteristic!, type: .withResponse)
    }
    
    private func saveResultData(_ resultDataController: ResultDataController) {
        self.resultDataController = resultDataController
        onSuccessCallback(.gotData)
    }
    
    // MARK: - central manager callbacks
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            onFailCallback(FailCodes.bluetoothIsOff)
        } else {
            isCentralManagerReady = true
            centralManager!.scanForPeripherals(withServices: [ContecUUIDs.mainService], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        onDiscoverCallback(peripheral, advertisementData, RSSI)
    }
    
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            peripheral.discoverServices([ContecUUIDs.mainService])
        } else {
            onFailCallback(FailCodes.periferalIsNotFromThisQueue)
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            print("Failed to disconnect from peripheral \(peripheral), error: \(error?.localizedDescription ?? "no error description")")
            return
        }
        
        self.peripheral = nil
        isPeriferalReady = false
        
        onSuccessCallback(SuccessCodes.disconnected)
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Failed to discover services, error: \(error?.localizedDescription ?? "failed to obtain error description")")
            onFailCallback(FailCodes.failedToDiscoverServiceError)
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                if service.uuid == ContecUUIDs.mainService {
                    peripheral.discoverCharacteristics([
                        ContecUUIDs.getDataCharacteristic,
                        ContecUUIDs.sendDataCharacteristic
                    ], for: service)
                }
            }
        }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Failed to discover characteristics for service \(service.uuid), error: \(error?.localizedDescription ?? "no error description")")
            return
        }
        guard let discoveredCharacteristics = service.characteristics else {
            print("peripheralDidDiscoverCharacteristics called for empty characteristics for service \(service.uuid)")
            return
        }
        
        for characteristic in discoveredCharacteristics {
            if characteristic.uuid == ContecUUIDs.sendDataCharacteristic {
                sendDataCharacteristic = characteristic
            }
            else if characteristic.uuid == ContecUUIDs.getDataCharacteristic {
                getDataCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        
        if sendDataCharacteristic != nil && getDataCharacteristic != nil {
            isPeriferalReady = true
            onSuccessCallback(.connected)
        }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else {
            print("didUpdateValueFor characteristic with emty data")
            return
        }
        
        let int8Array = data.map { Int8(bitPattern: $0) }
        
        //        print("Reciving...", int8Array)
        
        contecDeviceController!.onDataReceived(data: int8Array)
    }
}
