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
    
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button("Close", action: { isPresented.toggle() })
                    .padding()
                Spacer()
            }
            HStack {
                if bleController.connectingPeripheral == nil {
                    ProgressView()
                        .padding(.trailing, 1)
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
            }
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
                            HapticFeedbackController.shared.play(.rigid)
                            self.bleController.connect(peripheral: device)
                        }
                    }
                }
            }
        }
    }
}

//struct ConnectView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectView()
//    }
//}
