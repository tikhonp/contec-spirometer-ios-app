//
//  DataSerializer.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 24.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation
import SwiftUI


///// All data in bytes to send to contec device
//class DataSerializer {
//
//    /// Generates hash from ``[Int]`` and appends element
//    /// - Parameter data: Int Array where hash calculate and store
//    /// - Returns: Modified Int Array
//    private func addHash(_ data: [Int8]) -> [Int8] {
//        var data = data
//        var hash = 0
//
//        data.forEach { value in
//            hash = Int(hash + (Int(value) & 255))
//        }
//
//        data.append(Int8(hash & 127))
//        return data
//    }
//
//    /// Convert ``Int8``  to ``UInt8``
//    /// - Parameter x: Input number Int8
//    /// - Returns: UInt8 number
//    private func IntToUInt8(_ x: Int8) -> UInt8 {
//        let x = Int(x)
//        return UInt8(x > -1 ? x : x + 256)
//    }
//
//    /// Generate Data from Int8 array
//    /// - Parameter data: Input Int8 array
//    /// - Returns: Data
//    private func fromArray(_ data: [Int8]) -> Data {
//        return Data(data.map(IntToUInt8))
//    }
//
//    public func doubleNumber(i1: Int8, i2: Int8) -> Data {
//        let intArray = addHash([-111, i1, i2])
//        return fromArray(intArray)
//    }
//
//    /// Get bytes Data for request to download data from contec device
//    /// - Returns: Data
//    public func getDataRequest() -> Data {
//        return fromArray([Int8.min, 0])
//    }
//
//    public func generateDataForSyncTime() -> Data {
//        let date = Date()
//        let calendar = Calendar.current
//        let since1970 = date.timeIntervalSince1970
//        let milliseconds = Int((since1970 - since1970.rounded(.towardZero)) * 1000)
//
//        var intArray: [Int8] = [
//            Int8.min,
//            Int8((calendar.component(.year, from: date) - 2000) & 127),
//            Int8(calendar.component(.month, from: date) & 15),
//            Int8(calendar.component(.day, from: date)),
//            Int8(calendar.component(.hour, from: date)),
//            Int8(calendar.component(.minute, from: date)),
//            Int8(calendar.component(.second, from: date)),
//            Int8(milliseconds & 127),
//            Int8((milliseconds >> 7) & 127)
//        ]
//        intArray = addHash(intArray)
//        let byteArray = intArray.map(IntToUInt8)
//
//        return Data(byteArray)
//    }
//
//    private func generate_single_number_data(number: Int8) -> Data {
//        var intArray: [Int8] = [number]
//        intArray = addHash(intArray)
//        let byteArray = intArray.map(IntToUInt8)
//        return Data(byteArray)
//    }
//
//    public func generate_data_step_2() -> Data {
//        return generate_single_number_data(number: -126)
//    }
//
//    public func generate_data_step_3() -> Data {
//        return generate_single_number_data(number: -108)
//    }
//
//    public func generateDataForGotPredictedValuesBEXP() -> Data {
//        let byteArray = [-112, 16].map(IntToUInt8)
//        return Data(byteArray)
//    }
//
//    public func generateDataForCheckRecords() -> Data {
//        return doubleNumber(i1: 0, i2: 1)
//    }
//
//    public func generateDataForCaptureRecord() -> Data {
//        var intArray: [Int8] = [-110, 0]
//        intArray = addHash(intArray)
//        let byteArray = intArray.map(IntToUInt8)
//        return Data(byteArray)
//    }
//}
//


class DataSerializer {
    private func get_hash(data: [Int]) -> Int {
        var hash = 0
        
        for i in 0..<(data.count - 1) {
            hash = Int(hash + (Int(data[i]) & 255))
        }

        return hash & 127
    }
    
    private func java_byte_array_to_UIInt8(_ x: Int) -> UInt8 {
        return UInt8(x > -1 ? x : x + 256)
    }
    
    public func getDataRequest() -> Data {
        let byteArray = [Int(Int8.min), 0].map(java_byte_array_to_UIInt8)
        return Data(byteArray)
    }
        
    public func generateDataForSyncTime() -> Data {
        let date = Date()
        let calendar = Calendar.current
        let since1970 = date.timeIntervalSince1970
        let milliseconds = Int((since1970 - since1970.rounded(.towardZero)) * 1000)
        
        var intArray: [Int] = [
            -125,
             (calendar.component(.year, from: date) - 2000) & 127,
             calendar.component(.month, from: date) & 15,
             calendar.component(.day, from: date),
             calendar.component(.hour, from: date),
             calendar.component(.minute, from: date),
             calendar.component(.second, from: date),
             milliseconds & 127,
             (milliseconds >> 7) & 127,
             0
        ]
        intArray[9] = get_hash(data: intArray)
        let byteArray = intArray.map(java_byte_array_to_UIInt8)
        
        return Data(byteArray)
    }
    
    public func generateDataForDelete() -> Data {
        return generate_single_number_data(number: -109)
    }
    
    private func generate_single_number_data(number: Int) -> Data {
        var intArray: [Int] = [number, 0]
        intArray[1] = get_hash(data: intArray)
        let byteArray = intArray.map(java_byte_array_to_UIInt8)
        return Data(byteArray)
    }
    
    public func doubleNumber(i1: Int, i2: Int) -> Data {
        var intArray: [Int] = [-111, i1, i2, 0]
        intArray[3] = get_hash(data: intArray)
        let byteArray = intArray.map(java_byte_array_to_UIInt8)
        return Data(byteArray)
    }
    
    public func generate_data_step_2() -> Data {
        return generate_single_number_data(number: -126)
    }
    
    public func generate_data_step_3() -> Data {
        return generate_single_number_data(number: -108)
    }
    
    public func generateDataForGotPredictedValuesBEXP() -> Data {
        let byteArray = [-112, 16].map(java_byte_array_to_UIInt8)
        return Data(byteArray)
    }
    
    public func generateDataForCheckRecords() -> Data {
        return doubleNumber(i1: 0, i2: 1)
    }
    
    public func generateDataForCaptureRecord() -> Data {
        var intArray: [Int] = [-110, 0, 0]
        intArray[2] = get_hash(data: intArray)
        let byteArray = intArray.map(java_byte_array_to_UIInt8)
        return Data(byteArray)
    }
}
