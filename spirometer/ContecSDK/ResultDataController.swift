//
//  ResultDataController.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 29.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//


/// Create, store and process data got from contec spirometer
class ResultDataController {
    
    /// Count of stored records
    public var measuringCount: Int!
    
    public var predictedValuesBexp: PredictedValuesBEXP?
    public var fVCDataBEXPs: [FVCDataBEXP] = []
    public var waveDatas: [WaveData] = []
    
    
    // MARK: - Private functions
    
    /// Concat two bytes to get `Double` value
    /// - Parameters:
    ///   - firstByte: first byte with Int8 type
    ///   - secondByte: second byte with Int8 type
    /// - Returns: computed double value
    private func computeDoubleFromTwoBytes(_ firstByte: Int8, _ secondByte: Int8) -> Double {
        return Double((Int(firstByte) & 127 | (Int(secondByte) & 127) << 7) & 65535) / 100.0
    }
    
    /// Concat two bytes to get `Int` value
    /// - Parameters:
    ///   - firstByte: first byte with Int8 type
    ///   - secondByte: second byte with Int8 type
    /// - Returns: computed int value
    private func computeIntFromTwoBytes(_ firstByte: Int8, _ secondByte: Int8) -> Int {
        return (Int(firstByte) & 127 | (Int(secondByte) & 127) << 7) & 65535
    }
    
    
    // MARK: - Public functions
    
    /// Save predicted values from byte array to ``predictedValuesBexp`` property
    /// - Parameter data: byte array with `Int8` type
    public func savePredictedValuesBEXP(data: [Int8]) {
        predictedValuesBexp = PredictedValuesBEXP(
            FVC: computeDoubleFromTwoBytes(data[2], data[3]),
            
            FEV1: computeDoubleFromTwoBytes(data[4], data[5]),
            PEF: computeDoubleFromTwoBytes(data[5], data[7]),
            FEV1_FVC: computeDoubleFromTwoBytes(data[8], data[9]),
            
            FEF25: computeDoubleFromTwoBytes(data[10], data[11]),
            FEF50: computeDoubleFromTwoBytes(data[12], data[13]) * 10.0,
            FEF75: computeDoubleFromTwoBytes(data[14], data[15]),
            FEF2575: computeDoubleFromTwoBytes(data[16], data[17]),
            
            FEV3: computeDoubleFromTwoBytes(data[18], data[19]),
            FEV6: computeDoubleFromTwoBytes(data[20], data[21])
        )
    }
    
    /// Save single record values from byte array to ``FVCDataBEXP`` instance
    /// and add it to ``fVCDataBEXPs`` array
    /// - Parameter data: byte array with `Int8` type
    public func saveFVCDataBEXP(data: [Int8]) {
        let measureType = Int(data[2])
        var measureTypeName: String = ""
        switch (measureType)  {
        case 0:
            measureTypeName = "ALL"
        case 1:
            measureTypeName = "FVC"
        case 2:
            measureTypeName = "VC"
        case 3:
            measureTypeName = "MVV"
        case 4:
            measureTypeName = "MV"
        default:
            print("ERROR: Decoding FVC data: UNKNOWN measureType CASE `\(measureType)`")
        }
        
        let standartType = Int(data[15])
        var standartTypeName: String = ""
        switch (standartType) {
        case 1:
            standartTypeName = "ERS"
        case 2:
            standartTypeName = "K_NUDSON"
        case 3:
            standartTypeName = "USA"
        default:
            print("ERROR: Decoding FVC data: UNKNOWN standartType CASE `\(standartType)`")
        }
        
        fVCDataBEXPs.append(FVCDataBEXP(
            measureType: measureType,
            measureTypeName: measureTypeName,
            number: computeIntFromTwoBytes(data[3], data[4]),
            
            year: Int(data[5]) + 2000,
            month: Int(data[6]),
            day: Int(data[7]),
            
            hour: Int(data[8]),
            minute: Int(data[9]),
            second: Int(data[10]),
            
            gender: Int(data[11]),
            age: Int(data[12]),
            height: computeIntFromTwoBytes(data[13], data[14]),
            
            standartType: standartType,
            standartTypeName: standartTypeName,
            drug: Int(data[16]) != 0 ? 1 : 0,
            
            FVC: computeDoubleFromTwoBytes(data[17], data[18]),
            
            FEV05: computeDoubleFromTwoBytes(data[19], data[20]),
            FEV1: computeDoubleFromTwoBytes(data[21], data[22]),
            FEV1_FVC: computeDoubleFromTwoBytes(data[23], data[24]) * 10,
            
            FEV3: computeDoubleFromTwoBytes(data[25], data[26]),
            FEV6: computeDoubleFromTwoBytes(data[27], data[28]),
            
            PEF: computeDoubleFromTwoBytes(data[29], data[30]),
            
            FEF25: computeDoubleFromTwoBytes(data[31], data[32]),
            FEF50: computeDoubleFromTwoBytes(data[33], data[34]),
            FEF75: computeDoubleFromTwoBytes(data[35], data[36]),
            FEF2575: computeDoubleFromTwoBytes(data[37], data[38]),
            
            PEFT: computeIntFromTwoBytes(data[39], data[40]),
            EVOL: computeIntFromTwoBytes(data[41], data[42])
        ))
    }
    
    /// Generate wave arrays from byte data with given frames count
    /// - Parameters:
    ///   - data: byte array with `Int8` type
    ///   - times: pointer to array of floats, times store
    ///   - speeds: pointer to array of floats, times speeds
    ///   - volumes: pointer to array of floats, times volumes
    ///   - framesCount: count of frames in wave data, arrays length
    public func generateWaveArrays(data: [Int8], times: inout [Float], speeds: inout [Float], volumes: inout [Float], framesCount: Int) {
        let v1 = Int((data[1] & 127 | data[0] & 1) << 7) & 65535
        let v2 = Int((data[2] & 127 | data[0] & 2) << 6) & 65535
        let v3 = Int((data[3] & 127 | data[0] & 4) << 5) & 65535
        let time = (v1 | v2 << 8 | v3 << 16) & 16777215
        times[framesCount] = Float(Double(time) / 10000.0)
        
        let v4 = Int((data[4] & 127 | data[0] & 8) << 4) & 65535
        let v5 = Int((data[5] & 127 | data[0] & 16) << 3) & 65535
        let speed = (v4 | v5 << 8) & 16777215
        speeds[framesCount] = Float(Double(speed) / 1000.0)
        
        let v6 = Int((data[6] & 127 | data[0] & 32) << 2) & 65535
        let v7 = Int((data[7] & 127 | data[0] & 64) << 1) & 65535
        let volume = (v6 | v7 << 8) & 16777215
        volumes[framesCount] = Float(Double(volume) / 1000.0)
    }
    
    /// Save wave data to ``WaveData`` instance stored in ``waveDatas`` array
    /// - Parameters:
    ///   - framesCount: count of frames in wave data, arrays length
    ///   - speeds: speeds float array
    ///   - volumes: volumes float array
    ///   - times: times float array
    public func saveWaveData(framesCount: Int, speeds: [Float], volumes: [Float], times: [Float]) {
        waveDatas.append(
            WaveData(waveCount: framesCount, speeds: speeds, volumes: volumes, times: times)
        )
    }
    
    /// Print result data for logging
    public func printData() {
        print(predictedValuesBexp ?? "Predicted values BEXP is nil")
        print(fVCDataBEXPs)
        print(waveDatas)
    }
}
