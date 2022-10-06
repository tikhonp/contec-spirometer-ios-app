//
//  ContecDeviceController.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 24.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation

/// Implements steps and methods to communicate with contec spirometer
class ContecDeviceController {
    
    /// State encoded with bytes for different step in incoming spirometr data
    private struct stateValues {
        static let unknown: Int8 = 127
        static let firstStep: Int8 = -16
        static let secondStep: Int8 = -13
        static let thirdStep: Int8 = -14
        static let getPredictedValuesBEXP: Int8 = -28
        static let checkRecordsCount: Int8 = -32
        static let captureRecord: Int8 = -31
        static let seventhStep: Int8 = -30
        static let deleteDataResponse: Int8 = -29
    }
    
    /// All incoming data stores here
    private var incomingDataQueue = AsyncQueue<Int8>()
    
    /// Buffer for holding specific data pieces from ``incomingDataQueue`` and process it
    private var dataStorage = [Int8](repeating: 0, count: 128)
    
    /// Current process state, stores ``state`` values
    private var state: Int8 = stateValues.unknown
    
    private var dataSerializer = DataSerializer()
    
    /// Stores all processed incoming data
    private var resultDataController = ResultDataController()
    
    /// Choose to delete data after loading from spirometer
    private var deleteDataAfterSync = false
    
    // Callbacks
    private let writeValueCallback: (Data) -> Void
    private let saveResultDataCallback: (ResultDataController) -> Void
    private let onProgressUpdate: (Float) -> Void
    private let onContecDeviceUpdateStatusCallback: (StatusCodes) -> Void
    
    
    /// Initilize ``ContecDeviceController`` store all callbacks
    /// - Parameters:
    ///   - writeValueCallback: function gets ``Data`` object and sends it to spirometer
    ///   - saveResultDataCallback: save ``ResultDataController`` instance to display in view
    ///   - onProgressUpdate: push progress when data loading, from 0.0 to 1.0
    ///   - onContecDeviceUpdateStatusCallback: update status callback
    init(
        writeValueCallback: @escaping (Data) -> Void,
        saveResultDataCallback: @escaping (ResultDataController) -> Void,
        onProgressUpdate: @escaping (Float) -> Void,
        onContecDeviceUpdateStatusCallback: @escaping (StatusCodes) -> Void
    ) {
        self.writeValueCallback = writeValueCallback
        self.saveResultDataCallback = saveResultDataCallback
        self.onProgressUpdate = onProgressUpdate
        self.onContecDeviceUpdateStatusCallback = onContecDeviceUpdateStatusCallback
    }
    
    
    // MARK: - Main logic private functions
    
    
    /// Copy data from ``incomingDataQueue`` to array from specific index and with given length
    /// - Parameters:
    ///   - copyTo: array copy data to
    ///   - from: store data from this index in array
    ///   - length: length to store data from ``incomingDataQueue``
    private func copyDataToDataStorage(copyTo: inout [Int8], from: Int, length: Int) {
        var from = from, length = length, i = from
        
        while (i < (from + length)) {
            if (!incomingDataQueue.isEmpty) {
                guard let value = incomingDataQueue.dequeue() else { continue }
                copyTo[i] = value
                i += 1
            }
        }
    }
    
    /// Choose and process step
    private func chooseStep() {
        switch state {
        case stateValues.firstStep:
            Task {
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 1)
                writeValueCallback(dataSerializer.generateDataForSyncTime())
                state = stateValues.unknown
                onProgressUpdate(0.02)
            }
        case stateValues.secondStep:
            Task {
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 2)
                writeValueCallback(dataSerializer.getDataStepTwo())
                state = stateValues.unknown
                onProgressUpdate(0.04)
            }
        case stateValues.thirdStep:
            Task {
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 7)
                writeValueCallback(dataSerializer.getDataStepThree())
                state = stateValues.unknown
                onProgressUpdate(0.06)
            }
        case stateValues.getPredictedValuesBEXP:
            Task {
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 22)
                resultDataController.savePredictedValuesBEXP(data: dataStorage)
                writeValueCallback(dataSerializer.generateDataForGotPredictedValuesBEXP())
                state = stateValues.unknown
                onProgressUpdate(0.1)
            }
        case stateValues.checkRecordsCount:
            Task {
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 9)
                resultDataController.measuringCount = (Int(dataStorage[1]) & 127 | (Int(dataStorage[2]) & 127) << 7) & 65535
                if resultDataController.measuringCount == 0 {
                    self.saveResultDataCallback(self.resultDataController)
                    return
                }
                writeValueCallback(dataSerializer.generateDataForCheckRecords())
                state = stateValues.unknown
                print("Records to capture: ", resultDataController.measuringCount ?? "measuringCount is nil")
                onProgressUpdate(0.15)
            }
        case stateValues.captureRecord:
            Task {
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 43)
                if !(dataStorage[1] != 127 && dataStorage[1] != 126) { return }
                if resultDataController.saveFVCDataBEXP(data: dataStorage) == nil {
                    onContecDeviceUpdateStatusCallback(.failedToFetchData)
                    return
                }
                writeValueCallback(dataSerializer.generateDataForCaptureRecord())
                state = stateValues.unknown
            }
        case stateValues.seventhStep:
            Task {
                print(incomingDataQueue.getElements)
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 4)
                
                let currentRecord = Int(dataStorage[1]) & 127 | (Int(dataStorage[2]) & 127) << 7
                let maxFramesCount = Int(dataStorage[3]) & 127 | (Int(dataStorage[4]) & 127) << 7
                
                var times = [Float](repeating: 0, count: maxFramesCount)
                var speeds = [Float](repeating: 0, count: maxFramesCount)
                var volumes = [Float](repeating: 0, count: maxFramesCount)
                var currentFrame = 0
//                print("Max frames: \(maxFramesCount)")
                while maxFramesCount > currentFrame {
//                    print("Current frame: \(currentFrame)")
                    var bufferByteData = [Int8](repeating: 0, count: 8)
                    copyDataToDataStorage(copyTo: &bufferByteData, from: 0, length: 8)
//                    print("Queue: \(incomingDataQueue.getElements) -> \(bufferByteData)")
                    resultDataController.generateWaveArrays(data: bufferByteData, times: &times, speeds: &speeds, volumes: &volumes, framesCount: currentFrame)
                    currentFrame += 1
//                    print("Arrays: \nSpeeds: \(speeds)\nVolumes: \(volumes)\nTimes: \(times)\n\n")
                }
                resultDataController.saveWaveData(framesCount: currentFrame, speeds: speeds, volumes: volumes, times: times)
                //                copyDataToDataStorage(copyTo: &dataStorage, from: 5, length: 19)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    //                    print(self.incomingDataQueue.getElements)
                    //                    print(self.incomingDataQueue.getElements.count)
                    self.incomingDataQueue.clear()
                    if currentRecord == self.resultDataController.measuringCount {
                        if self.deleteDataAfterSync {
                            self.writeValueCallback(self.dataSerializer.doubleNumber(i1: 127, i2: 1))
                        } else {
                            self.writeValueCallback(self.dataSerializer.doubleNumber(i1: 126, i2: 1))
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.incomingDataQueue.clear()
                            self.state = stateValues.unknown
                        }
                        self.saveResultDataCallback(self.resultDataController)
                        return
                    }
                    
                    let newProgress = 0.2 + (0.8 * (Float(currentRecord) / Float(self.resultDataController.measuringCount!)))
                    self.onProgressUpdate(newProgress)
                    
                    self.state = stateValues.unknown
                    self.writeValueCallback(self.dataSerializer.doubleNumber(i1: 1, i2: 1))
                }
                
            }
        case stateValues.deleteDataResponse:
            copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 2)
            if dataStorage[1] == 0 {
                DispatchQueue.main.async {
                    self.onContecDeviceUpdateStatusCallback(.deletedData)
                }
            } else {
                print("failed")
            }
        case stateValues.unknown:
            print("Case set to unknown!")
        default:
            print("CHOOSE CASE, unknown case: ", state)
            print("Queue: ", incomingDataQueue.getElements)
            DispatchQueue.main.async {
                self.onContecDeviceUpdateStatusCallback(.failedToFetchData)
            }
        }
    }
    
    
    // MARK: - Public functions
    
    /// Priocess data from spirometr callback
    /// - Parameter data: Int8 array with bytes
    public func onDataReceived(data: [Int8]) {
        for i in 0..<(data.count) {
            incomingDataQueue.enqueue(data[i])
        }
        
        if state == stateValues.unknown {
            var value: Int8 = 0
            while value == 0 {
                guard let v = incomingDataQueue.dequeue() else { return }
                value = v
            }
            state = value
            chooseStep()
        }
    }
    
    /// Get data request
    /// - Parameter deleteDataAfterSync: Choose to delete data after loading from spirometer
    public func getData(deleteDataAfterSync: Bool) {
        self.deleteDataAfterSync = deleteDataAfterSync
        state = stateValues.unknown
        incomingDataQueue.clear()
        writeValueCallback(dataSerializer.getDataRequest())
    }
    
    /// Delete data request
    func deleteData() {
        state = stateValues.unknown
        incomingDataQueue.clear()
        writeValueCallback(dataSerializer.generateDataForDelete())
    }
    
    /// Set user params to spirometer request
    func setUserParams(userParams: UserParams) {
        print("here")
        incomingDataQueue.clear()
        let data = dataSerializer.generateDataForSetUserParams(userParams: userParams)
        print(data)
        writeValueCallback(data)
    }
}
