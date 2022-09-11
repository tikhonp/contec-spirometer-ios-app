//
//  ConnectView.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 31.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI

struct ConnectView: View {
    @EnvironmentObject var bleController: BLEController
    
    var body: some View {
        VStack {
            HStack {
                Text("Device search...")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.trailing)
                if bleController.connectingPeripheral == nil {
                    ProgressView()
                }
            }
            .padding(.top)
            .padding(.bottom, 5)
            Text("Select your Contec Spirometer from the list below, the saved devices will be connected automatically.")
                .font(.body)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
                .padding(.leading, 40)
                .padding(.trailing, 40)
            List{
                ForEach(self.bleController.devices, id: \.self) { device in
                    if ((device.name) != nil) {
                        HStack {
                            Text(device.name!)
                            if bleController.connectingPeripheral == device {
                                Spacer()
                                ProgressView()
                            }
                        }
                        .onTapGesture {
                            self.bleController.connect(peripheral: device)
                        }
                    }
                }
            }
            Spacer()
            Text("(c) Medsenger Sync")
                .font(.caption)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
        }
        .onAppear(perform: bleController.discover)
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView()
    }
}
