//
//  DataSerializer.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 24.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation


/// All data in bytes to send to contec device
class DataSerializer {
    
    // MARK: - Private functions
    
    /// Generates hash from int array and returns it
    /// - Parameter data: int array
    /// - Returns: int hash
    private func getHash(_ data: [Int]) -> Int {
        var hash: Int = 0
        
        for i in 0..<(data.count - 1) {
            hash = Int(hash + (Int(data[i]) & 255))
        }
        
        return hash & 127
    }
    
    /// Convert int to byte `UInt8` value
    /// - Parameter x: int value to convert
    /// - Returns: output UInt8 value
    private func javaByteArrayToUIInt8(_ x: Int) -> UInt8 {
        return UInt8(x > -1 ? x : x + 256)
    }
    
    /// Generate data with single byte and hash
    /// - Parameter number: number to paste to data
    /// - Returns: Data object
    private func generateSingleNumberData(number: Int) -> Data {
        var intArray: [Int] = [number, 0]
        intArray[1] = getHash(intArray)
        let byteArray = intArray.map(javaByteArrayToUIInt8)
        return Data(byteArray)
    }
    
    
    // MARK: - Public functions with varible data generation
    
    /// Generate data with two given bytes -111 in begining and hash
    /// - Parameters:
    ///   - i1: first number
    ///   - i2: second number
    /// - Returns: Data object
    public func doubleNumber(i1: Int, i2: Int) -> Data {
        var intArray: [Int] = [-111, i1, i2, 0]
        intArray[3] = getHash(intArray)
        let byteArray = intArray.map(javaByteArrayToUIInt8)
        return Data(byteArray)
    }
    
    
    // MARK: - Loading data requests
    
    /// Request to start loading data process
    public func getDataRequest() -> Data {
        let byteArray = [Int(Int8.min), 0].map(javaByteArrayToUIInt8)
        return Data(byteArray)
    }
    
    /// Generate datetime data to sync spirometer time
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
        intArray[9] = getHash(intArray)
        let byteArray = intArray.map(javaByteArrayToUIInt8)
        
        return Data(byteArray)
    }
    
    /// Submit step two on loading data
    public func getDataStepTwo() -> Data {
        return generateSingleNumberData(number: -126)
    }
    
    /// Submit step three on loading data
    public func getDataStepThree() -> Data {
        return generateSingleNumberData(number: -108)
    }
    
    /// Submit step after got predictef values BEXP on loading data
    public func generateDataForGotPredictedValuesBEXP() -> Data {
        let byteArray = [-112, 16].map(javaByteArrayToUIInt8)
        return Data(byteArray)
    }
    
    /// Submit step after check avalible records on loading data
    public func generateDataForCheckRecords() -> Data {
        return doubleNumber(i1: 0, i2: 1)
    }
    
    /// Submit step after capture record wave data on loading data
    public func generateDataForCaptureRecord() -> Data {
        var intArray: [Int] = [-110, 0, 0]
        intArray[2] = getHash(intArray)
        let byteArray = intArray.map(javaByteArrayToUIInt8)
        return Data(byteArray)
    }
    
    
    // MARK: - Public functions for specific requests
    
    /// Request to delete saved records from spirometer
    public func generateDataForDelete() -> Data {
        return generateSingleNumberData(number: -109)
    }
    
    /// Generate data for settign user params based on user params class
    /// - Parameter userParams: ``UserParams`` class
    /// - Returns: Data object
    public func generateDataForSetUserParams(userParams: UserParams) -> Data {
        var intArray: [Int] = [
            -117,
             userParams.height >> 5 | userParams.height >> 4,
             userParams.sex.rawValue,
             userParams.age,
             userParams.height,
             userParams.weight,
             userParams.standart.rawValue,
             userParams.smoke.rawValue,
             0
        ]
        intArray[8] = getHash(intArray)
        let byteArray = intArray.map(javaByteArrayToUIInt8)
        return Data(byteArray)
    }
}
