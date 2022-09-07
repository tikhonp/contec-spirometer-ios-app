//
//  ConnectView.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 31.08.2022.
//

import SwiftUI

struct ConnectView: View {
    @EnvironmentObject var bleController: BLEController
    
    var body: some View {
        VStack {
//            Spacer()
            HStack {
                Text("Поиск устройств...")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                if bleController.connectingPeripheral == nil {
                    ProgressView()
                }
            }
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
        }
        .onAppear(perform: bleController.discover)
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView()
    }
}
