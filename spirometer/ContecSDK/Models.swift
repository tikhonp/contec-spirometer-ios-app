//
//  Models.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 22.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation


// MARK: - Enums

enum measureModeEnum {
    case ALL
    case FVC
    case VC
    case MVV
    case MV
}


enum standartEnum: Int {
    case ECCS = 1
    case KNUDSON = 2
    case USA = 3
}


enum sexEnum: Int {
    case MALE = 0
    case FEMALE = 1
}


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
    let measureTypeName: measureModeEnum
    let number: Int // Number of record in array
    
    // MARK: - DateTime data
    let year: Int
    let month: Int
    let day: Int
    
    let hour: Int
    let minute: Int
    let second: Int
    
    // MARK: - Personal data
    let gender: sexEnum
    let age: Int
    let height: Int
    
    let standartType: Int
    let standartTypeName: standartEnum
    
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


/// User params can bet set in spirometer
class UserParams {
    public enum smokeEnum: Int {
        case NOSMOKE = 0
        case SMOKE = 1
    }
    
    var age: Int
    var height: Int
    var weight: Int
    var measureMode: measureModeEnum
    var sex: sexEnum
    var smoke: smokeEnum
    var standart: standartEnum
    
    init(
        age: Int, height: Int, weight: Int,
        measureMode: measureModeEnum, sex: sexEnum,
        smoke: smokeEnum, standart: standartEnum
    ) {
        self.age = age
        self.height = height
        self.weight = weight
        self.measureMode = measureMode
        self.sex = sex
        self.smoke = smoke
        self.standart = standart
    }
}
