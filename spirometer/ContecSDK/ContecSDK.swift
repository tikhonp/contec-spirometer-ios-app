//
//  ContecSDK.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 24.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation
import CoreBluetooth


/// Status codes for different events situations
enum StatusCodes {
    case bluetoothIsOff
    case bluetoothIsOn
    case periferalIsNotFromThisQueue
    case failedToDiscoverServiceError
    case periferalIsNotReady
    case failedToDeleteData
    case deletedData
    case disconnected
    case gotData
    case connected
    case failedToFetchData
}


/// Main Contec Spirometer controller class
class ContecSDK: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    /// Contec device UUIDs for using with GATT services and
    private struct ContecUUIDs {
        static let mainService = CBUUID.init(string: "0000ff12-0000-1000-8000-00805f9b34fb")
        
        static let sendDataCharacteristic = CBUUID.init(string: "0000ff01-0000-1000-8000-00805f9b34fb")
        static let getDataCharacteristic = CBUUID.init(string: "0000ff02-0000-1000-8000-00805f9b34fb")
    }
    
    
    /// Status update callback with ``StatusCodes`` status
    private let onUpdateStatusCallback: (StatusCodes) -> Void
    
    /// Callback for discovered devices after call ``discover()``
    private let onDiscoverCallback: (_ peripheral: CBPeripheral, _ advertisementData: [String : Any], _ RSSI: NSNumber) -> Void
    
    /// from 0.0 to 1.0
    private let onProgressUpdate: (_ progress: Float) -> Void
    
    
    private var centralManager: CBCentralManager?
    private var isCentralManagerReady: Bool = false
    
    private var peripheral: CBPeripheral!
    private var isPeriferalReady: Bool = false
    
    private var sendDataCharacteristic: CBCharacteristic?
    private var getDataCharacteristic: CBCharacteristic?
    
    
    private var contecDeviceController: ContecDeviceController?
    
    public var resultDataController: ResultDataController?
    
    
    /// Initialization of ``ContecSDK`` class
    /// - Parameters:
    ///   - onUpdateStatusCallback: update status callback for differrent events
    ///   - onDiscoverCallback: on device discover push to display it in view list
    ///   - onProgressUpdate: update progress number
    init (
        onUpdateStatusCallback: @escaping (StatusCodes) -> Void,
        onDiscoverCallback: @escaping (CBPeripheral, [String : Any], NSNumber) -> Void,
        onProgressUpdate: @escaping (Float) -> Void
    ) {
        self.onUpdateStatusCallback = onUpdateStatusCallback
        self.onDiscoverCallback = onDiscoverCallback
        self.onProgressUpdate = onProgressUpdate
    }
    
    
    // MARK: - public methods
    
    /// Request to load data from contec device
    /// - Parameter deleteDataAfterSync: Choose to delete data after loading from spirometer
    public func getData(deleteDataAfterSync: Bool = false) {
        if isPeriferalReady {
            resultDataController = nil
            contecDeviceController?.getData(deleteDataAfterSync: deleteDataAfterSync)
        } else {
            onUpdateStatusCallback(.periferalIsNotReady)
        }
    }
    
    /// Request to delete records data from contec device
    public func deleteData() {
        if isPeriferalReady {
            contecDeviceController?.deleteData()
        } else {
            onUpdateStatusCallback(.periferalIsNotReady)
        }
    }
    
    /// Set user params to contec device
    /// - Parameter userParams: ``UserParams`` class
    public func setUserParams(userParams: UserParams) {
        if isPeriferalReady {
            contecDeviceController?.setUserParams(userParams: userParams)
        } else {
            onUpdateStatusCallback(.periferalIsNotReady)
        }
    }
    
    /// Start BLE devices discovering
    ///
    /// Discovered devices with type ``CBPeripheral`` will be go
    /// to `onDiscoverCallback` mentioned in ``init(onSuccessCallback:onDiscoverCallback:onFailCallback:)``
    public func discover() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /// Stop BLE devices discovering
    public func stopDiscover() {
        if isCentralManagerReady {
            centralManager!.stopScan()
        } else {
            onUpdateStatusCallback(.bluetoothIsOff)
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
            contecDeviceController = ContecDeviceController(
                writeValueCallback: sendData,
                saveResultDataCallback: saveResultData,
                onProgressUpdate: onProgressUpdate,
                onContecDeviceUpdateStatusCallback: onContecDeviceupdateStatusCallback)
        } else {
            onUpdateStatusCallback(.bluetoothIsOff)
        }
    }
    
    /// Disconnect peripheral
    public func disconnect() {
        if isPeriferalReady {
            if isCentralManagerReady {
                centralManager!.cancelPeripheralConnection(peripheral)
            } else {
                onUpdateStatusCallback(.bluetoothIsOff)
            }
        } else {
            onUpdateStatusCallback(.periferalIsNotReady)
        }
    }
    
    
    // MARK: - private functions for ``ContecDevice`` usage
    
    private func sendData(_ data: Data) {
        peripheral.writeValue(data, for: sendDataCharacteristic!, type: .withResponse)
    }
    
    private func saveResultData(_ resultDataController: ResultDataController) {
        self.resultDataController = resultDataController
        onUpdateStatusCallback(.gotData)
    }
    
    private func onContecDeviceupdateStatusCallback(_ statusCode: StatusCodes) {
        onUpdateStatusCallback(statusCode)
    }
    
    // MARK: - central manager callbacks
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            onUpdateStatusCallback(.bluetoothIsOff)
        } else {
            onUpdateStatusCallback(.bluetoothIsOn)
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
            onUpdateStatusCallback(.periferalIsNotFromThisQueue)
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        isPeriferalReady = false
        
        onUpdateStatusCallback(.disconnected)
        
        guard error == nil else {
            print("Failed to disconnect from peripheral \(peripheral), error: \(error?.localizedDescription ?? "no error description")")
            return
        }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Failed to discover services, error: \(error?.localizedDescription ?? "failed to obtain error description")")
            onUpdateStatusCallback(.failedToDiscoverServiceError)
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
            onUpdateStatusCallback(.connected)
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
