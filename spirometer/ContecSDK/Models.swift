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
    let PEF: Double
    let FEV1_FVC: Double
    
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
    let measureType: Int
    let measureTypeName: String
    let number: Int // Number of record in array
    
    // MARK: - DateTime data
    let year: Int
    let month: Int
    let day: Int
    
    let hour: Int
    let minute: Int
    let second: Int
    
    // MARK: - Personal data
    let gender: Int
    let age: Int
    let height: Int
    
    let standartType: Int
    let standartTypeName: String
    
    let drug: Int
    
    // MARK: - BEXP data
    let FVC: Double
    
    let FEV05: Double
    let FEV1: Double
    let FEV1_FVC: Double
    
    let FEV3: Double
    let FEV6: Double
    
    let PEF: Double
    
    let FEF25: Double
    let FEF50: Double
    let FEF75: Double
    let FEF2575: Double
    
    let PEFT: Int
    let EVOL: Int
    
    /// Date object from date data
    var date: Date {
        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = DateComponents(timeZone: TimeZone.current, year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        return calendar.date(from: dateComponents)!
    }
    
    /// Dict for json generation for send to medsenger
    var recordJson: [String : Any] {
        return [
            "FVC": FVC,
            "FEV1": FEV1,
            "FEV1%": FEV1_FVC,
            "PEF": PEF,
            "FEF25": FEF25,
            "FEF50": FEF50,
            "FEF75": FEF75,
            "FEF2575": FEF2575,
            "FEV05": FEV05,
            "FEV3": FEV3,
            "FEV6": FEV6,
            "PEFT": PEFT,
            "EVOL": EVOL
        ]
    }
}


/// Record wave data for graphs
struct WaveData {
    let waveCount: Int
    
    let speeds: [Float]
    let volumes: [Float]
    let times: [Float]
}
