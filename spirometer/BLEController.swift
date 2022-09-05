//
//  BLEController.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 31.08.2022.
//

import SwiftUI
import Foundation
import CoreBluetooth


struct ErrorInfo: Identifiable {
    var id: Int
    let title: String
    let description: String
}

final class BLEController: NSObject, ObservableObject {
    @Published var devices: [CBPeripheral] = []
    @Published var isConnected = false
    @Published var connectingPeripheral: CBPeripheral?
    @Published var resultDataController: ResultDataController?
    @Published var error: ErrorInfo?
    @Published var progress: Float = 0.0
    
    private var contecSDK: ContecSDK!
    
    func startContecSDK() {
        contecSDK = ContecSDK(onSuccessCallback: onSuccessCallback, onDiscoverCallback: onDiscoverCallback, onFailCallback: onFailCallBack, onProgressUpdate: onProgressUpdate)
    }
    
    func deleteData() {
        contecSDK.deleteData()
    }
    
    func onProgressUpdate(_ progress: Float) {
        DispatchQueue.main.async {
            self.progress = progress
        }
    }
    
    func onSuccessCallback(successCode: SuccessCodes) {
        DispatchQueue.main.async {
            print(successCode)
            switch successCode {
            case .disconnected:
                print("Disconnected")
                self.isConnected = false
                self.connectingPeripheral = nil
            case .gotData:
                self.resultDataController = self.contecSDK.resultDataController
                self.resultDataController?.printData()
            case .connected:
                self.isConnected = true
            case .deletedData:
                self.error = ErrorInfo(id: 6, title: "Данные успешно удалены", description: "")
            }
        }
    }
    
    func onDiscoverCallback(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (!devices.contains(peripheral)) {
            devices.append(peripheral)
        }
        
        guard let savedSpirometrUUID = UserDefaults.savedSpirometrUUID else { return }
        
        if peripheral.identifier.uuidString == savedSpirometrUUID {
            connect(peripheral: peripheral)
        }
    }
    
    func onFailCallBack(failCode: FailCodes) {
        print("Fail ", failCode)
        DispatchQueue.main.async {
            switch failCode {
            case .bluetoothIsOff:
                self.error = ErrorInfo(id: 1, title: "Блютуз выключен", description: "")
            case .periferalIsNotFromThisQueue:
                self.error = ErrorInfo(id: 2, title: "Ошибка", description: "")
            case .failedToDiscoverServiceError:
                self.error = ErrorInfo(id: 3, title: "Сервис не найден", description: "")
            case .periferalIsNotReady:
                self.error = ErrorInfo(id: 4, title: "Устройство не готово", description: "")
            case .failedToDeleteData:
                self.error = ErrorInfo(id: 5, title: "Ошибка при удалении данных", description: "")
            }
        }
    }
    
    func connect(peripheral: CBPeripheral) {
        UserDefaults.savedSpirometrUUID = peripheral.identifier.uuidString
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
        if resultDataController == nil || resultDataController?.measuringCount == 0 {
            self.error = ErrorInfo(id: 7, title: "Нет данных для загрузки", description: "")
            return
        }
        
        guard let medsengerContractId = UserDefaults.medsengerContractId, let medsengerAgentToken = UserDefaults.medsengerAgentToken else {
            self.error = ErrorInfo(id: 8, title: "Нет токена medsenger", description: "")
            return
        }
        
        for i in 0..<resultDataController!.measuringCount {
            let record = resultDataController!.fVCDataBEXP[i]
            
            let calendar = Calendar(identifier: .gregorian)
            let dateComponents = DateComponents(timeZone: TimeZone.current, year: record.year, month: record.month, day: record.day, hour: record.hour, minute: record.minute)
            let date = calendar.date(from: dateComponents)!
            
            let data = [
                "contract_id": medsengerContractId,
                "agent_token": medsengerAgentToken,
                "timestamp": date.timeIntervalSince1970,
                "measurement": [
                    "FVC": record.FVC,
                    "FEV1": record.FEV1,
                    "FEV1%": record.FEV1_FVC,
                    "PEF": record.PEF,
                    "FEF25": record.FEF25,
                    "FEF50": record.FEF50,
                    "FEF75": record.FEF75,
                    "FEF2575": record.FEF2575,
                    "FEV05": record.FEV05,
                    "FEV3": record.FEV3,
                    "FEV6": record.FEV6,
                    "PEFT": record.PEFT,
                    "EVOL": record.EVOL
                ]
            ] as [String : Any]
            
            postRequest(jsonData: data, url: "https://contec.medsenger.ru/api/receive")
        }
        
        deleteData()
        getData()
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
}
