//
//  Models.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 22.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation


/// Predicted values from personal data in spirometr
struct PredictedValuesBEXP {
    let FVC: Double
    
    let FEV1: Double
    let FEV1_FVC: Double
    
    let PEF: Double
    
    let FEF25: Double
    let FEF50: Double
    let FEF75: Double
    let FEF2575: Double
    
    let FEV3: Double
    let FEV6: Double
}


// MARK: - Single record models

/// One record from spirometr
struct FVCDataBEXP {
    // MARK: - Personal data
    let age: Int
    let gender: Int
    let height: Int
    let drug: Int
    
    
    // MARK: - DateTime data
    let day: Int
    let month: Int
    let year: Int
    
    let hour: Int
    let minute: Int
    let second: Int

    
    // MARK: - BEXP data
    let FVC: Double
    
    let FEV1: Double
    let FEV1_FVC: Double
    
    let PEF: Double
    
    let FEF25: Double
    let FEF50: Double
    let FEF75: Double
    let FEF2575: Double
    
    let FEV05: Double
    let FEV3: Double
    let FEV6: Double
    
    let PEFT: Int
    let EVOL: Int
    
    
    // MARK: - Meta data
    let measureType: Int
    let measureTypeName: String
    let number: Int // Number of record in array
    let standartType: Int
    let standartTypeName: String
}


/// Record wave data for graphs
struct WaveData {
    let waveCount: Int
    
    let speeds: [Float]
    let volumes: [Float]
    let times: [Float]
}
