//
//  BLEController.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 31.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI
import Foundation
import CoreBluetooth


struct ErrorInfo: Identifiable {
    var id = UUID()
    let title: String
    let description: String
}

class ErrorAlerts: NSObject {
    static let error = ErrorInfo(
        title: LocalizedStringKey("Ops! Something bad happened!").stringValue(),
        description: LocalizedStringKey("Detailed information about this error has automaticly been recordedand we have been notified.").stringValue())
    static let invalidPeriferal = ErrorInfo(
        title: LocalizedStringKey("Ops! Invalid peripheral found!").stringValue(),
        description: LocalizedStringKey("Detailed information about this error has automaticly been recordedand we have been notified.").stringValue())
    static let serviceNotFound = ErrorInfo(
        title: LocalizedStringKey("Ops! Bluetooth service on peripheral device not found!").stringValue(),
        description: LocalizedStringKey("Detailed information about this error has automaticly been recordedand we have been notified.").stringValue())
    static let deviceIsNotReady = ErrorInfo(
        title: LocalizedStringKey("Device is not ready").stringValue(),
        description: LocalizedStringKey("Try to reload application.").stringValue())
    static let failedToDeleteData = ErrorInfo(
        title: LocalizedStringKey("Failed to delete data from spirometer").stringValue(),
        description: LocalizedStringKey("Try to reload application.").stringValue())
    static let disconnected = ErrorInfo(
        title: LocalizedStringKey("Device disconnected").stringValue(), description: "")
    static let emptyDataToUploadToMedsenger = ErrorInfo(
        title: LocalizedStringKey("Empty data").stringValue(),
        description: LocalizedStringKey("Try to reload application.").stringValue())
    static let medsengerTokenIsEmpty = ErrorInfo(
        title: LocalizedStringKey("Authorization in Medsenger is not successful").stringValue(),
        description: LocalizedStringKey("Go to the Medsenger app for authorization").stringValue())
}

final class BLEController: NSObject, ObservableObject {
    @Published var devices: [CBPeripheral] = []
    @Published var isConnected = false
    @Published var connectingPeripheral: CBPeripheral?
    @Published var resultDataController: ResultDataController?
    @Published var error: ErrorInfo?
    @Published var progress: Float = 0.0
    @Published var userParams = UserParams(
        age: 0, height: 0, weight: 0, measureMode: .VC, sex: .MALE, smoke: .NOSMOKE, standart: .ECCS)
    @Published var isBluetoothOn = true
    
    private var contecSDK: ContecSDK!
    
    private func throwAlert(_ errorInfo: ErrorInfo) {
        self.error = errorInfo
    }
    
    func startContecSDK() {
        contecSDK = ContecSDK(
            onUpdateStatusCallback: onStatusUpdateCallback,
            onDiscoverCallback: onDiscoverCallback,
            onProgressUpdate: onProgressUpdate
        )
    }
    
    func deleteData() {
        contecSDK.deleteData()
    }
    
    func onProgressUpdate(_ progress: Float) {
        DispatchQueue.main.async {
            self.progress = progress
        }
    }
    
    func onStatusUpdateCallback(statusCode: StatusCodes) {
        DispatchQueue.main.async {
            print("Updated status code: \(statusCode)")
            switch statusCode {
            case .bluetoothIsOff:
                self.isBluetoothOn = false
            case .bluetoothIsOn:
                self.isBluetoothOn = true
            case .periferalIsNotFromThisQueue:
                self.throwAlert(ErrorAlerts.invalidPeriferal)
            case .failedToDiscoverServiceError:
                self.throwAlert(ErrorAlerts.serviceNotFound)
            case .periferalIsNotReady:
                self.throwAlert(ErrorAlerts.deviceIsNotReady)
            case .failedToDeleteData:
                self.throwAlert(ErrorAlerts.failedToDeleteData)
            case .deletedData:
                let resultDataController = ResultDataController()
                resultDataController.measuringCount = 0
                resultDataController.predictedValuesBexp = self.resultDataController?.predictedValuesBexp
                self.resultDataController = resultDataController
            case .disconnected:
                self.isConnected = false
                self.connectingPeripheral = nil
                self.devices = []
                self.throwAlert(ErrorAlerts.disconnected)
            case .gotData:
                self.resultDataController = self.contecSDK.resultDataController
//                self.resultDataController?.printData()
            case .connected:
                self.isConnected = true
            }
        }
    }
    
    func onDiscoverCallback(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (!devices.contains(peripheral)) {
            devices.append(peripheral)
        }
        
        guard let savedSpirometrUUID = UserDefaults.savedSpirometrUUID else { return }
        
        if peripheral.identifier.uuidString == savedSpirometrUUID {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.connect(peripheral: peripheral)
            }
        }
    }
    
    
    
    func connect(peripheral: CBPeripheral) {
        if UserDefaults.saveUUID {
            UserDefaults.savedSpirometrUUID = peripheral.identifier.uuidString
        }
        connectingPeripheral = peripheral
        contecSDK.connect(peripheral)
    }
    
    func discover() {
        contecSDK.discover()
    }
    
    func getData() {
        resultDataController = nil
        progress = 0
        contecSDK.getData()
    }
    
    func sendDataToMedsenger() {
        DispatchQueue.main.async { [self] in
            if resultDataController == nil || resultDataController?.measuringCount == 0 {
                self.throwAlert(ErrorAlerts.emptyDataToUploadToMedsenger)
                return
            }
            
            guard let medsengerContractId = UserDefaults.medsengerContractId, let medsengerAgentToken = UserDefaults.medsengerAgentToken else {
                self.throwAlert(ErrorAlerts.medsengerTokenIsEmpty)
                return
            }
            
            for i in 0..<resultDataController!.measuringCount {
                let record = resultDataController!.fVCDataBEXPs[i]
                
                let data = [
                    "contract_id": medsengerContractId,
                    "agent_token": medsengerAgentToken,
                    "timestamp": record.date.timeIntervalSince1970,
                    "measurement": record.recordJson
                ] as [String : Any]
                
                print(data)
                
                let jsonData = try? JSONSerialization.data(withJSONObject: data)
                guard let url = URL(string: "https://contec.medsenger.ru/api/receive") else {
                    print("Invalid url!")
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("\(String(describing: jsonData?.count))", forHTTPHeaderField: "Content-Length")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                    guard error != nil else {
                        print(error?.localizedDescription ?? "No data")
                        return
                    }
                    
                }).resume()
            }
            deleteData()
        }
    }
    
    func updatePropertiesFromDeeplink(url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("Error with create url components")
            return
        }
        
        guard let queryItems = urlComponents.queryItems else { return }
        
        for queryItem in queryItems {
            switch queryItem.name {
            case "contract_id":
                guard let medsengerContractIdValue = queryItem.value else {
                    print("Empty medsenger contract id")
                    return
                }
                UserDefaults.medsengerContractId = Int(medsengerContractIdValue)
            case "agent_token":
                UserDefaults.medsengerAgentToken = queryItem.value
            default:
                print("Deeplink url query item \(queryItem.name): \(queryItem.value ?? "Nil value")")
            }
        }
    }
    
    func initilizeUserParams() {
        userParams = resultDataController!.userParams
    }
    
    func setUserParams() {
        if userParams.age == 0 || userParams.weight == 0 || userParams.height == 0 {
//            self.error = ErrorInfo(id: 6, title: "Не валидные значения", description: "")
            return
        }
        
        DispatchQueue.main.async {
            self.contecSDK.setUserParams(userParams: self.userParams)
        }
    }
}
