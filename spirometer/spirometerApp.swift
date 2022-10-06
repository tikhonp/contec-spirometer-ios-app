//
//  spirometerApp.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 29.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI
import Sentry

@main
struct spirometerApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        #if DEBUG
        print("Running app in debug mode")
        #else
        guard let dsn = Bundle.main.infoDictionary?["SENTRY_DSN"] as? String else {
            fatalError("Missing sentry DSN")
        }
        SentrySDK.start { options in
            options.dsn = dsn
            options.debug = false
            
            options.tracesSampleRate = 1.0
        }
        #endif
        UserDefaults.registerDefaultValues()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
