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
        .onAppear(perform: { bleController.startContecSDK() })
        .environmentObject(bleController)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
