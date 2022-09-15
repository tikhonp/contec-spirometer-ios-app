//
//  UserDefaults+AppPrefs.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 05.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation


extension UserDefaults {
    private enum Keys {
        static let savedSpirometrUUIDkey = "savedSpirometrUUID"
        static let medsengerContractIdKey = "medsengerContractId"
        static let medsengerAgentTokenKey = "medsengerAgentToken"
        static let saveUUIDkey = "saveUUID"
        static let lastUploadedDateKey = "lastUploadedDate"
    }
    
    class var savedSpirometrUUID: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.savedSpirometrUUIDkey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.savedSpirometrUUIDkey)
        }
    }
    
    class var saveUUID: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.saveUUIDkey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.saveUUIDkey)
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
    
    class var lastUpladedDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: Keys.lastUploadedDateKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.lastUploadedDateKey)
        }
    }
    
    class func registerDefaultValues() {
        UserDefaults.standard.register(defaults: [
            Keys.saveUUIDkey: true,
        ])
    }
}
