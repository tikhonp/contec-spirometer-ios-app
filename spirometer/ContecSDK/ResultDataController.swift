//
//  ResultDataController.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 29.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation


class ResultDataController {
    public var measuringCount: Int?
    
    var predictedValuesBexp: PredictedValuesBEXP?
    var fVCDataBEXP: [FVCDataBEXP] = []
    var waveData: [WaveData] = []
    
    public func savePredictedValuesBEXP(data: [Int8]) {
        predictedValuesBexp = PredictedValuesBEXP(
            FEF25: (Double((Int(data[10]) & 127 | (Int(data[11]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FEF2575: (Double((Int(data[16]) & 127 | (Int(data[17]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FEF50: (Double((Int(data[12]) & 127 | (Int(data[13]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FEF75: (Double((Int(data[14]) & 127 | (Int(data[15]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FEV1: (Double((Int(data[4]) & 127 | (Int(data[5]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FEV1_FVC: (Double((Int(data[8]) & 127 | (Int(data[9]) & 127) << 7) & 65535) * 1.0) / 10.0,
            FEV3: (Double((Int(data[18]) & 127 | (Int(data[19]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FEV6: (Double((Int(data[20]) & 127 | (Int(data[21]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FVC: (Double((Int(data[2]) & 127 | (Int(data[3]) & 127) << 7) & 65535) * 1.0) / 100.0,
            PEF: (Double((Int(data[6]) & 127 | (Int(data[7]) & 127) << 7) & 65535) * 1.0) / 100.0
        )
    }
    
    public func saveFVCDataBEXP(data: [Int8]) {
        var measureType: Int = 0
        var measureTypeName: String = ""
        switch (data[2] & 127)  {
        case 0:
            measureType = 0
            measureTypeName = "ALL"
        case 1:
            measureType = 1
            measureTypeName = "FVC"
        case 2:
            measureType = 2
            measureTypeName = "VC"
        case 3:
            measureType = 3
            measureTypeName = "MVV"
        case 4:
            measureType = 4
            measureTypeName = "MV"
        default:
            print("FVC data UNKNOWN CASE")
        }
        
        var standartType: Int = 0
        var standartTypeName: String = ""
        switch (data[15] & 127) {
        case 1:
            standartType = 1
            standartTypeName = "ERS"
        case 2:
            standartType = 2
            standartTypeName = "K_NUDSON"
        case 3:
            standartType = 3
            standartTypeName = "USA"
        default:
            print("FVC data UNKNOWN CASE")
        }
        
        fVCDataBEXP.append(FVCDataBEXP(
            age: Int(data[12]) & 127,
            day: Int(data[7]) & 127,
            drug: (Int(data[12]) & 127) != 0 ? 1 : 0,
            EVOL: (Int(data[41]) & 127 | (Int(data[42]) & 127) << 7) & 65535,
            FEF25: (Double((Int(data[31]) & 127 | (Int(data[32]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FEF2575: (Double((Int(data[37]) & 127 | (Int(data[38]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FEF50: (Double((Int(data[33]) & 127 | (Int(data[34]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FEF75: (Double((Int(data[35]) & 127 | (Int(data[36]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FEV05: (Double((Int(data[19]) & 127 | (Int(data[20]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FEV1: (Double((Int(data[21]) & 127 | (Int(data[22]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FEV1_FVC: (Double((Int(data[23]) & 127 | (Int(data[24]) & 127) << 7) & 65535) * 1.0) / 10.0,
            FEV3: (Double((Int(data[25]) & 127 | (Int(data[26]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FEV6: (Double((Int(data[27]) & 127 | (Int(data[28]) & 127) << 7) & 65535) * 1.0) / 100.0,
            FVC: (Double((Int(data[17]) & 127 | (Int(data[18]) & 127) << 7) & 65535) * 1.0) / 100.0,
            PEF: (Double((Int(data[29]) & 127 | (Int(data[30]) & 127) << 7) & 65535) * 1.0) / 100.0,
            PEFT: (Int(data[39]) & 127 | (Int(data[40]) & 127) << 7) & 65535,
            gender: Int(data[11]) & 127,
            height: (Int(data[13]) & 127 | (Int(data[14]) & 127) << 7) & 65535,
            hour: Int(data[8]) & 127,
            measureType: measureType, measureTypeName: measureTypeName,
            minute: Int(data[9]) & 127,
            month: Int(data[6]) & 127,
            number: (Int(data[3]) & 127 | (Int(data[4]) & 127) << 7) & 65535,
            second: Int(data[10]) & 127,
            year: Int(data[5] & 127) + 2000,
            standartType: standartType, standartTypeName: standartTypeName
        ))
    }
    
    public func saveWaveArrays(data: [Int8], times: inout [Float], speeds: inout [Float], volumes: inout [Float], framesCount: Int) {
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
    
    public func saveWaveData(framesCount: Int, speeds: [Float], volumes: [Float], times: [Float]) {
        waveData.append(
            WaveData(waveCount: framesCount, speeds: speeds, volumes: volumes, times: times)
        )
    }
    
    func printData() {
        print(predictedValuesBexp ?? "Predicted values BEXP is nil")
        print(fVCDataBEXP)
        print(waveData)
    }
}
