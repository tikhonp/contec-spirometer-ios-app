//
//  BluetoothIsOffView.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 11.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI

struct BluetoothIsOffView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image("BluetoothOff")
                .resizable()
                .frame(width: 60, height: 60)
                .padding()
            Text("Bluetooth Disabled")
                .font(.title2)
                .fontWeight(.bold)
            Text("Turn off flight mode or enable bluetooth.")
                .font(.body)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
                .padding(.leading, 40)
                .padding(.trailing, 40)
        }
    }
}

struct BluetoothIsOffView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothIsOffView()
    }
}
