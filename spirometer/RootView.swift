//
//  ContentView.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 29.08.2022.
//

import SwiftUI


struct RootView: View {
    @StateObject var bleController = BLEController()
    
    var body: some View
    {
        ZStack {
            if bleController.isConnected {
                ConnectedView()
            } else {
                ConnectView()
            }
        }
        .alert(item: $bleController.error, content: { error in
            Alert(
                title: Text(error.title),
                message: Text(error.description)
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
