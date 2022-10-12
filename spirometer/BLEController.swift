//
//  BLEController.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 31.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Sentry
import SwiftUI
import CoreData
import Foundation
import CoreBluetooth

/// Main controller for applicatin and Contec Spirometer connection
final class BLEController: NSObject, ObservableObject {
    
    // MARK: - private vars
    
    private let persistenceController = PersistenceController.shared
    private var contecSDK: ContecSDK!
    private var healthKitAvailible = false
    
    // MARK: - published vars
    
    @Published var isConnected = false
    @Published var isBluetoothOn = true
    @Published var fetchingDataWithSpirometer = false
    @Published var presentUploadToMedsenger = UserDefaults.medsengerAgentToken != nil && UserDefaults.medsengerContractId != nil
    @Published var showBluetoothIsOffWarning = false
    @Published var showSelectDevicesInfo = false
    
    @Published var progress: Float = 0.0
    
    @Published var devices: [CBPeripheral] = []
    @Published var connectingPeripheral: CBPeripheral?
    
    @Published var error: ErrorInfo?
    
    @Published var userParams = UserParams(
        age: 0, height: 0, weight: 0, measureMode: .VC, sex: .MALE, smoke: .NOSMOKE, standart: .ECCS)
    
    @Published var navigationBarTitleStatus = LocalizedStringKey("Your measurements").stringValue()
    
    @Published var sendingToMedsengerStatus: Int = 0
    
    // MARK: - private functions
    
    /// Throw alert from ``ErrorAlerts`` class
    /// - Parameters:
    ///   - errorInfo: ``ErrorInfo`` instance
    ///   - feedbackType: optional feedback type if you need haptic feedback
    private func throwAlert(_ errorInfo: ErrorInfo, _ feedbackType: UINotificationFeedbackGenerator.FeedbackType? = nil) {
        DispatchQueue.main.async {
            if let feedbackType = feedbackType {
                HapticFeedbackController.shared.prepareNotify()
                HapticFeedbackController.shared.notify(feedbackType)
            }
            self.error = errorInfo
        }
    }
    
    /// Conver ``ResultDataController`` to ``CoreData`` records
    /// - Parameter resultData: result data contriller item
    private func processResultData(resultData: ResultDataController) {
        let context = persistenceController.container.viewContext
        
        let fvcDataBexpPredictedModel = persistenceController.addFVCdataBEXPpredictedModel(fvcDataBexpPredicted: resultData.predictedValuesBexp!, context: context)
        
        for (index, record) in resultData.fVCDataBEXPs.enumerated() {
            // Check if record already exists by hash
            let fetchRequest = FVCDataBEXPmodel.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "objectHash == %ld", record.objectHash, #keyPath(FVCDataBEXPmodel.objectHash))
            
            guard let objects = try? context.fetch(fetchRequest) else {
                guard let error = error as? Error else {
                    print("Core Data failed to fetch hash")
                    return
                }
                print("Core Data failed to fetch: \(error.localizedDescription)")
                SentrySDK.capture(error: error)
                return
            }
            
            if objects.isEmpty {
                guard let waveData = resultData.waveDatas[safe: index] else {
                    print("Failed to get wave data")
                    return
                }
                persistenceController.addFVCDataBEXPmodel(fVCDataBEXP: record, waveData: waveData, fvcDataBexpPredictedModel: fvcDataBexpPredictedModel, context: context)
                
                if healthKitAvailible {
                    HealthKitController.saveRecord(fvc: record.FVC, fev1: record.FEV1, pef: record.PEF, date: record.date)
                }
            } else {
                print("Skipping already synchronized objects")
            }
        }
    }
    
    private func startHealthKit() {
        HealthKitController.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                self.healthKitAvailible = false
                return
            }
            self.healthKitAvailible = true
            print("HealthKit Successfully Authorized.")
        }
    }
    
    private func startContecSDK() {
        contecSDK = ContecSDK(
            onUpdateStatusCallback: onStatusUpdateCallback,
            onDiscoverCallback: onDiscoverCallback,
            onProgressUpdate: onProgressUpdate
        )
    }
    
    // MARK: - callbacks for contec SDK usage
    
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
                self.navigationBarTitleStatus = LocalizedStringKey("Waiting Bluetooth...").stringValue()
                self.isBluetoothOn = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if !self.isBluetoothOn {
                        self.showBluetoothIsOffWarning = true
                    }
                }
            case .bluetoothIsOn:
                self.showBluetoothIsOffWarning = false
                if !self.isBluetoothOn {
                    self.isBluetoothOn = true
                    self.discover()
                }
            case .periferalIsNotFromThisQueue:
                self.throwAlert(ErrorAlerts.invalidPeriferal, .error)
            case .failedToDiscoverServiceError:
                self.throwAlert(ErrorAlerts.serviceNotFound, .error)
            case .periferalIsNotReady:
                self.throwAlert(ErrorAlerts.deviceIsNotReady, .error)
            case .failedToDeleteData:
                self.throwAlert(ErrorAlerts.failedToDeleteData, .error)
            case .deletedData:
                print("Data was deleted")
            case .disconnected:
                self.fetchingDataWithSpirometer = false
                self.isConnected = false
                self.connectingPeripheral = nil
                self.devices = []
                self.throwAlert(ErrorAlerts.disconnected, .warning)
                self.discover()
            case .gotData:
                self.progress = 1
                let resultDataController = self.contecSDK.resultDataController!
                self.userParams = resultDataController.userParams
                self.processResultData(resultData: resultDataController)
                self.fetchingDataWithSpirometer = false
                self.navigationBarTitleStatus = LocalizedStringKey("Your measurements").stringValue()
                HapticFeedbackController.shared.play(.light)
            case .connected:
                HapticFeedbackController.shared.play(.light)
                self.showSelectDevicesInfo = false
                self.isConnected = true
                self.getData()
            case .failedToFetchData:
                self.fetchingDataWithSpirometer = false
                self.throwAlert(ErrorAlerts.failedToFetchDataError, .error)
            }
        }
    }
    
    func onDiscoverCallback(peripheral: CBPeripheral, _: [String : Any], _ RSSI: NSNumber) {
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
    
    // MARK: - public functions controlls BLE connections
    
    /// Call on app appear
    func initilizeBleController() {
        startContecSDK()
        startHealthKit()
    }
    
    func discover() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if !self.isConnected {
                self.showSelectDevicesInfo = true
            }
        }
        navigationBarTitleStatus = LocalizedStringKey("Search...").stringValue()
        contecSDK.discover()
    }
    
    func connect(peripheral: CBPeripheral) {
        navigationBarTitleStatus = LocalizedStringKey("Connecting...").stringValue()
        if UserDefaults.saveUUID {
            UserDefaults.savedSpirometrUUID = peripheral.identifier.uuidString
        }
        connectingPeripheral = peripheral
        contecSDK.connect(peripheral)
    }
    
    func disconnect() {
        contecSDK.disconnect()
    }
    
    func getData() {
        self.navigationBarTitleStatus = LocalizedStringKey("Fetching data...").stringValue()
        fetchingDataWithSpirometer = true
        progress = 0
        contecSDK.getData(deleteDataAfterSync: true)
    }
    
    func setUserParams() {
        if userParams.age == 0 || userParams.weight == 0 || userParams.height == 0 {
            throwAlert(ErrorAlerts.invalidUserParams, .error)
            return
        }
        
        DispatchQueue.main.async {
            self.contecSDK.setUserParams(userParams: self.userParams)
        }
    }
    
    // MARK: - Public functions to use in views
    
    func sendDataToMedsenger() {
        DispatchQueue.main.async {
            self.sendingToMedsengerStatus = 1
            
            let objects: [FVCDataBEXPmodel]? = {
                let context = self.persistenceController.container.viewContext
                if let recentFetchDate = UserDefaults.lastUpladedDate {
                    let fetchRequest: NSFetchRequest<FVCDataBEXPmodel> = FVCDataBEXPmodel.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "%@ <= %K", recentFetchDate as NSDate, #keyPath(FVCDataBEXPmodel.date))
                    
                    do {
                        return try context.fetch(fetchRequest)
                    } catch {
                        self.sendingToMedsengerStatus = 0
                        print("Core Data failed to fetch: \(error.localizedDescription)")
                        SentrySDK.capture(error: error)
                        return nil
                    }
                } else {
                    let fetchRequest: NSFetchRequest<FVCDataBEXPmodel> = FVCDataBEXPmodel.fetchRequest()
                    
                    do {
                        return try context.fetch(fetchRequest)
                    } catch {
                        self.sendingToMedsengerStatus = 0
                        print("Core Data failed to fetch: \(error.localizedDescription)")
                        SentrySDK.capture(error: error)
                        return nil
                    }
                }
            }()
            
            guard let records = objects else {
                self.sendingToMedsengerStatus = 0
                print("Failed to fetch data, objects are nil!")
                return
            }
            
            if records.isEmpty {
                self.sendingToMedsengerStatus = 0
                self.throwAlert(ErrorAlerts.emptyDataToUploadToMedsenger)
                return
            }
            
            guard let medsengerContractId = UserDefaults.medsengerContractId, let medsengerAgentToken = UserDefaults.medsengerAgentToken else {
                self.sendingToMedsengerStatus = 0
                self.throwAlert(ErrorAlerts.medsengerTokenIsEmpty)
                return
            }
            
            for record in records {
                let data = [
                    "contract_id": medsengerContractId,
                    "agent_token": medsengerAgentToken,
                    "timestamp": record.date!.timeIntervalSince1970,
                    "measurement": [
                        "FVC": record.fvc,
                        "FEV1": record.fev1,
                        "FEV1%": record.fev1_fvc,
                        "PEF": record.pef,
                        "FEF25": record.fef25,
                        "FEF50": record.fef50,
                        "FEF75": record.fef75,
                        "FEF2575": record.fef2575,
                        "FEV05": record.fef25,
                        "FEV3": record.fev3,
                        "FEV6": record.fev6,
                        "PEFT": record.peft,
                        "EVOL": record.evol
                    ]
                ] as [String : Any]
                
                guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
                    self.sendingToMedsengerStatus = 0
                    print("Failed to serialize data with JSON")
                    return
                }
                
                guard let url = URL(string: "https://contec.medsenger.ru/api/receive") else {
                    self.sendingToMedsengerStatus = 0
                    print("Invalid medsenger url!")
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("\(String(describing: jsonData.count))", forHTTPHeaderField: "Content-Length")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                    DispatchQueue.main.async {
                        guard error == nil else {
                            self.sendingToMedsengerStatus = 0
                            if (error as! URLError).code == URLError.notConnectedToInternet {
                                self.throwAlert(ErrorAlerts.failedToConnectToNetwork)
                            } else {
                                print("Failed to make HTTP reuest to medsenger: \(error!.localizedDescription)")
                                SentrySDK.capture(error: error!)
                            }
                            return
                        }
                        if self.sendingToMedsengerStatus == records.count {
                            UserDefaults.lastUpladedDate = Date()
                            self.throwAlert(ErrorAlerts.dataSuccessfullyUploadedToMedsenger)
                            self.sendingToMedsengerStatus = 0
                        } else {
                            self.sendingToMedsengerStatus += 1
                        }
                    }
                }).resume()
            }
        }
    }
    
    func resetMedsengerCredentials() {
        DispatchQueue.main.async {
            UserDefaults.medsengerAgentToken = nil
            UserDefaults.medsengerContractId = nil
            self.presentUploadToMedsenger = false
        }
    }
    
    func updatePropertiesFromDeeplink(url: URL) {
        DispatchQueue.main.async {
            guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
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
                self.presentUploadToMedsenger = true
            }
        }
    }
}
