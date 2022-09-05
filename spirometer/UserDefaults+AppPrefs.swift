//
//  UserDefaults+AppPrefs.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 05.09.2022.
//

import Foundation


extension UserDefaults {
    private enum Keys {
        static let savedSpirometrUUIDkey = "savedSpirometrUUID"
        static let medsengerContractIdKey = "medsengerContractId"
        static let medsengerAgentTokenKey = "medsengerAgentToken"
    }

    class var savedSpirometrUUID: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.savedSpirometrUUIDkey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.savedSpirometrUUIDkey)
        }
    }
    
    class var medsengerContractId: Int? {
        get {
            return UserDefaults.standard.integer(forKey: Keys.medsengerContractIdKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.medsengerContractIdKey)
        }
    }
    
    class var medsengerAgentToken: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.medsengerAgentTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.medsengerAgentTokenKey)
        }
    }
}
