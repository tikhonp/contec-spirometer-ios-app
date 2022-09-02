//
//  Models.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 22.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation


struct PredictedValuesBEXP {
    let FEF25: Double
    let FEF2575: Double
    let FEF50: Double
    let FEF75: Double
    let FEV1: Double
    let FEV1_FVC: Double
    let FEV3: Double
    let FEV6: Double
    let FVC: Double
    let PEF: Double
}


struct FVCDataBEXP {
    let age: Int
    let day: Int
    let drug: Int
    
    let EVOL: Int
    let FEF25: Double
    let FEF2575: Double
    let FEF50: Double
    let FEF75: Double
    let FEV05: Double
    let FEV1: Double
    let FEV1_FVC: Double
    let FEV3: Double
    let FEV6: Double
    let FVC: Double
    let PEF: Double
    let PEFT: Int
    
    let gender: Int
    let height: Int
    let hour: Int
    let measureType: Int
    let measureTypeName: String
    let minute: Int
    let month: Int
    let number: Int
    let second: Int
    let year: Int
    let standartType: Int
    let standartTypeName: String
}

struct WaveData {
    let waveCount: Int
    let speeds: [Float]
    let volumes: [Float]
    let times: [Float]
}
