//
//  ContentView.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 29.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI


struct RootView: View {
    @StateObject var bleController = BLEController()
    
    var body: some View
    {
        ConnectedView()
            .alert(item: $bleController.error, content: { error in
                Alert(
                    title: Text(error.title),
                    message: Text(error.description),
                    dismissButton: .default(Text("Close"))
                )
            })
            .onAppear(perform: { bleController.startContecSDK() })
            .environmentObject(bleController)
            .onOpenURL { url in
                bleController.updatePropertiesFromDeeplink(url: url)
            }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
