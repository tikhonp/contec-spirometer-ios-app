//
//  RecordLabel.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 02.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI

struct RecordLabel: View {
    let fVCDataBEXP: FVCDataBEXP
    
    let emojis = ["🫁", "🩹", "🧪", "🌡", "🌬", "💨"]
    
    let dateFormatter: DateFormatter
    
    init(fVCDataBEXP: FVCDataBEXP) {
        self.fVCDataBEXP = fVCDataBEXP
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Text("\(emojis.randomElement() ?? "")")
                Text(fVCDataBEXP.date, formatter: dateFormatter)
                Text(fVCDataBEXP.date, style: .time)
            }
            .padding()
            Text(String(format: "FVC: %.2f", fVCDataBEXP.FVC))
                .padding(.bottom)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor)
        .cornerRadius(10)
        .shadow(radius: 10)
        .padding([.bottom, .trailing, .leading])
        
    }
}

struct RecordLabel_Previews: PreviewProvider {
    static var previews: some View {
        RecordLabel(fVCDataBEXP: FVCDataBEXP(measureType: 1, measureTypeName: .FVC, number: 1, year: 2022, month: 8, day: 29, hour: 17, minute: 30, second: 36, gender: .MALE, age: 39, height: 175, standartType: 1, standartTypeName: .ECCS, drug: 1, FVC: 5.1, FEV05: 0.0, FEV1: 4.95, FEV1_FVC: 97.1, FEV3: 0.0, FEV6: 0.0, PEF: 9.33, FEF25: 8.01, FEF50: 6.52, FEF75: 3.91, FEF2575: 6.14, PEFT: 291, EVOL: 79))
    }
}
