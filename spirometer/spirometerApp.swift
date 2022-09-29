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
        SentrySDK.start { options in
            options.dsn = "https://1249e55e37dd4d40bdf29daf38c15654@o1075119.ingest.sentry.io/6755116"
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
