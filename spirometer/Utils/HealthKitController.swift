//
//  HealthKitController.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 30.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation
import HealthKit


class HealthKitController {
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        guard let forcedVitalCapacity = HKObjectType.quantityType(forIdentifier: .forcedVitalCapacity),
              let forcedExpiratoryVolume1 = HKObjectType.quantityType(forIdentifier: .forcedExpiratoryVolume1),
              let peakExpiratoryFlowRate = HKObjectType.quantityType(forIdentifier: .peakExpiratoryFlowRate) else {
            completion(false, HealthkitSetupError.dataTypeNotAvailable)
            return
        }
        
        let healthKitTypesToWrite: Set<HKSampleType> = [forcedVitalCapacity,
                                                        forcedExpiratoryVolume1,
                                                        peakExpiratoryFlowRate]
        
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: []) { (success, error) in
            completion(success, error)
        }
    }
    
    class func saveRecord(fvc: Double, fev1: Double, pef: Double, date: Date) {
        guard let forcedVitalCapacityType = HKQuantityType.quantityType(forIdentifier: .forcedVitalCapacity),
              let forcedExpiratoryVolume1Type = HKQuantityType.quantityType(forIdentifier: .forcedExpiratoryVolume1),
              let peakExpiratoryFlowRateType = HKQuantityType.quantityType(forIdentifier: .peakExpiratoryFlowRate) else {
            print("Body Mass Index Type is no longer available in HealthKit")
            return
        }
        
        let forcedVitalCapacityQuantity = HKQuantity(unit: HKUnit.liter(), doubleValue: fvc)
        let forcedVitalCapacitySample = HKQuantitySample(type: forcedVitalCapacityType, quantity: forcedVitalCapacityQuantity, start: date, end: date)
        
        let forcedExpiratoryVolume1Quantity = HKQuantity(unit: HKUnit.liter(), doubleValue: fev1)
        let forcedExpiratoryVolume1Sample = HKQuantitySample(type: forcedExpiratoryVolume1Type, quantity: forcedExpiratoryVolume1Quantity, start: date, end: date)
        
        let peakExpiratoryFlowRateQuantity = HKQuantity(unit: HKUnit(from: "L/s"), doubleValue: pef)
        let peakExpiratoryFlowRateSample = HKQuantitySample(type: peakExpiratoryFlowRateType, quantity: peakExpiratoryFlowRateQuantity, start: date, end: date)
        
        var samples = [HKQuantitySample]()
        samples.append(forcedVitalCapacitySample)
        samples.append(forcedExpiratoryVolume1Sample)
        samples.append(peakExpiratoryFlowRateSample)
        
        HKHealthStore().save(samples) { (success, error) in
            if let error = error {
                print("Error Saving health kit: \(error.localizedDescription)")
            } else {
                print("Successfully saved Health Kit")
            }
        }
    }
}
