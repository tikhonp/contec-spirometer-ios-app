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
    @State var error: ErrorInfo?
    @State var progress: Float = 0.0
    
    private var contecSDK: ContecSDK!
    
    func startContecSDK() {
        contecSDK = ContecSDK(onSuccessCallback: onSuccessCallback, onDiscoverCallback: onDiscoverCallback, onFailCallback: onFailCallBack, onProgressUpdate: onProgressUpdate)
    }
    
    func deleteData() {
        contecSDK.deleteData()
    }
    
    func onProgressUpdate(_ progress: Float) {
        self.progress = progress
    }
    
    func onSuccessCallback(successCode: SuccessCodes) {
        switch successCode {
        case .disconnected:
            print("Disconnected")
            isConnected = false
        case .gotData:
            resultDataController = contecSDK.resultDataController
        case .connected:
            isConnected = true
        }
    }
    
    func onDiscoverCallback(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (!devices.contains(peripheral)) {
            devices.append(peripheral)
        }
    }
    
    func onFailCallBack(failCode: FailCodes) {
        print("Fail ", failCode)
        switch failCode {
        case .bluetoothIsOff:
            error = ErrorInfo(id: 1, title: "Блютуз выключен", description: "")
        case .periferalIsNotFromThisQueue:
            error = ErrorInfo(id: 2, title: "Ошибка", description: "")
        case .failedToDiscoverServiceError:
            error = ErrorInfo(id: 3, title: "Сервис не найден", description: "")
        case .periferalIsNotReady:
            error = ErrorInfo(id: 4, title: "Устройство не готово", description: "")
        }
    }
    
    func connect(peripheral: CBPeripheral) {
        connectingPeripheral = peripheral
        contecSDK.connect(peripheral)
    }
    
    func discover() {
        contecSDK.discover()
    }
    
    func getData() {
        contecSDK.getData()
    }
}
