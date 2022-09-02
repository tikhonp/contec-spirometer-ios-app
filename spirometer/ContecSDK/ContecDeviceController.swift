//
//  ContecDeviceController.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 24.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation


struct STATE {
    static let UNKNOWN: Int8 = 127
    static let FIRST_STEP: Int8 = -16
    static let SECOND_STEP: Int8 = -13
    static let THIRD_STEP: Int8 = -14
    static let getPredictedValuesBEXP: Int8 = -28
    static let checkRecordsCount: Int8 = -32
    static let captureRecord: Int8 = -31
    static let SEVENTH_STEP: Int8 = -30
    static let deleteDataResponse: Int8 = -29
}


struct Queue<T> {
    private let queue = DispatchQueue(label: "queue.operations", attributes: .concurrent)
    private var elements: [T] = []

    mutating func enqueue(_ value: T) {
        queue.sync(flags: .barrier) {
            self.elements.append(value)
        }
    }
    
    mutating func dequeue() -> T? {
        return queue.sync(flags: .barrier) {
            guard !self.elements.isEmpty else {
                return nil
            }
            return self.elements.removeFirst()
        }
    }
    
    mutating func clear() {
        queue.sync(flags: .barrier) {
            self.elements = []
        }
    }

    var head: T? {
        return queue.sync {
            return elements.first
        }
    }

    var tail: T? {
        return queue.sync {
            return elements.last
        }
    }
    
    var length: Int {
        return queue.sync {
            return elements.count
        }
    }
    
    var isEmpty: Bool {
        return queue.sync {
            return elements.isEmpty
        }
    }
    
    var getElements: [T] {
        return queue.sync {
            return elements
        }
    }
}


class ContecDeviceController {
    private var incomingDataQueue = Queue<Int8>()
    
    private var dataStorage = [Int8](repeating: 0, count: 128)
    
    private var state: Int8 = STATE.UNKNOWN
    
    private var dataSerializer = DataSerializer()
    
    private var writeValueCallback: (Data) -> Void
    private var saveResultDataCallback: (ResultDataController) -> Void
    private let onProgressUpdate: (_ progress: Float) -> Void
    
    private var resultDataController = ResultDataController()
    
    init(writeValueCallback: @escaping (Data) -> Void, saveResultDataCallback: @escaping (ResultDataController) -> Void, onProgressUpdate: @escaping (_ progress: Float) -> Void) {
        self.writeValueCallback = writeValueCallback
        self.saveResultDataCallback = saveResultDataCallback
        self.onProgressUpdate = onProgressUpdate
    }
    
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
    
    private func chooseStep() {
        switch state {
        case STATE.FIRST_STEP:
            Task {
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 1)
                writeValueCallback(dataSerializer.generateDataForSyncTime())
                state = STATE.UNKNOWN
                onProgressUpdate(0.02)
            }
        case STATE.SECOND_STEP:
            Task {
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 2)
                writeValueCallback(dataSerializer.generate_data_step_2())
                state = STATE.UNKNOWN
                onProgressUpdate(0.04)
            }
        case STATE.THIRD_STEP:
            Task {
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 7)
                writeValueCallback(dataSerializer.generate_data_step_3())
                state = STATE.UNKNOWN
                onProgressUpdate(0.06)
            }
        case STATE.getPredictedValuesBEXP:
            Task {
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 22)
                resultDataController.savePredictedValuesBEXP(data: dataStorage)
                writeValueCallback(dataSerializer.generateDataForGotPredictedValuesBEXP())
                state = STATE.UNKNOWN
                onProgressUpdate(0.1)
            }
        case STATE.checkRecordsCount:
            Task {
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 9)
                resultDataController.measuringCount = (Int(dataStorage[1]) & 127 | (Int(dataStorage[2]) & 127) << 7) & 65535
                if resultDataController.measuringCount == 0 {
                    self.saveResultDataCallback(self.resultDataController)
                    return
                }
                writeValueCallback(dataSerializer.generateDataForCheckRecords())
                state = STATE.UNKNOWN
                print("Records to capture: ", resultDataController.measuringCount ?? "measuringCount is nil")
                onProgressUpdate(0.15)
            }
        case STATE.captureRecord:
            Task {
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 43)
                if !(dataStorage[1] != 127 && dataStorage[1] != 126) { return }
                resultDataController.saveFVCDataBEXP(data: dataStorage)
                writeValueCallback(dataSerializer.generateDataForCaptureRecord())
                state = STATE.UNKNOWN
            }
        case STATE.SEVENTH_STEP:
            Task {
                copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 4)
                
                let currentRecord = (Int(dataStorage[1]) & 127 | (Int(dataStorage[2]) & 127) << 7) & 65535
                let maxFramesCount = (Int(dataStorage[3]) & 127 | (Int(dataStorage[4]) & 127) << 7) & 65535
                
                var times = [Float](repeating: 0, count: maxFramesCount)
                var speeds = [Float](repeating: 0, count: maxFramesCount)
                var volumes = [Float](repeating: 0, count: maxFramesCount)
                var framesCount = 0
                
                print("Lalala", currentRecord, maxFramesCount)
                
                while maxFramesCount > framesCount {
                    var bufferByteData = [Int8](repeating: 0, count: 64)
                    copyDataToDataStorage(copyTo: &bufferByteData, from: 0, length: 8)
                    resultDataController.saveWaveArrays(data: bufferByteData, times: &times, speeds: &speeds, volumes: &volumes, framesCount: framesCount)
                    framesCount += 1
                }
                resultDataController.saveWaveData(framesCount: framesCount, speeds: speeds, volumes: volumes, times: times)
//                copyDataToDataStorage(copyTo: &dataStorage, from: 5, length: 19)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    print(self.incomingDataQueue.getElements)
                    print(self.incomingDataQueue.getElements.count)
                    self.incomingDataQueue.clear()
                    if currentRecord == self.resultDataController.measuringCount {
                        print("Exit")
                        self.writeValueCallback(self.dataSerializer.doubleNumber(i1: 126, i2: 1))
                        self.saveResultDataCallback(self.resultDataController)
                        return
                    }

                    let newProgress = 0.2 + (0.8 * (Float(currentRecord) / Float(self.resultDataController.measuringCount!)))
                    self.onProgressUpdate(newProgress)
                    
                    print("More")
                    self.state = STATE.UNKNOWN
                    self.writeValueCallback(self.dataSerializer.doubleNumber(i1: 1, i2: 1))
                }
                
            }
        case STATE.deleteDataResponse:
            copyDataToDataStorage(copyTo: &dataStorage, from: 1, length: 2)
            if dataStorage[1] == 0 {
                print("done")
            } else {
                print("failed")
            }
        case STATE.UNKNOWN:
            print("Case set to unknown!")
        default:
            print("CHOOSE CASE, unknown case: ", state)
            print("Queue: ", incomingDataQueue.getElements)
        }
    }
    
    func onDataReceived(data: [Int8]) {
        for i in 0..<(data.count) {
            incomingDataQueue.enqueue(data[i])
        }
        
        if state == STATE.UNKNOWN {
            guard let value = incomingDataQueue.dequeue() else { return }
            state = value
            chooseStep()
        }
    }
}
