//
//  ConnectLabel.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 16.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI

struct ConnectLabel: View {
    @Binding var isPresentedDeviceList: Bool
    
    @EnvironmentObject var bleController: BLEController
    
    var body: some View {
        VStack {
            HStack {
                if bleController.connectingPeripheral == nil {
                    Text("Device search...")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.trailing)
                    
                } else {
                    Text("Connecting...")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.trailing)
                }
                ProgressView()
                Button {
                    isPresentedDeviceList.toggle()
                } label: {
                    Text("Device List")
                }
            }
        }
        .padding(.top)
        .padding(.bottom, 5)
        .onAppear(perform: bleController.discover)
    }
}

//struct ConnectLabel_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectLabel()
//    }
//}
