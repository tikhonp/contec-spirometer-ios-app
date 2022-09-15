//
//  spirometerApp.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 29.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI

@main
struct spirometerApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        UserDefaults.registerDefaultValues()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
