//
//  RecordLabel.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 02.09.2022.
//

import SwiftUI

struct RecordLabel: View {
    let fVCDataBEXP: FVCDataBEXP
    
    let emojis = ["🫁", "🩹", "🧪", "🌡", "🌬", "💨"]
    
    var body: some View {
        VStack {
            Text("\(emojis.randomElement() ?? "") \(fVCDataBEXP.day).\(fVCDataBEXP.month).\(fVCDataBEXP.year) \(fVCDataBEXP.hour):\(fVCDataBEXP.minute)")
                .padding()
            Text(String(format: "FVC: %.2f", fVCDataBEXP.FVC))
                .padding(.bottom)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.accentColor)
        .cornerRadius(10)
        .shadow(radius: 10)
        .padding([.bottom, .trailing, .leading])
        
    }
}

struct RecordLabel_Previews: PreviewProvider {
    static var previews: some View {
        RecordLabel(fVCDataBEXP: FVCDataBEXP(age: 39, day: 29, drug: 1, EVOL: 79, FEF25: 8.01, FEF2575: 6.14, FEF50: 6.52, FEF75: 3.91, FEV05: 0.0, FEV1: 4.95, FEV1_FVC: 97.1, FEV3: 0.0, FEV6: 0.0, FVC: 5.1, PEF: 9.33, PEFT: 291, gender: 0, height: 175, hour: 17, measureType: 1, measureTypeName: "FVC", minute: 30, month: 8, number: 1, second: 36, year: 2022, standartType: 1, standartTypeName: "ERS"))
    }
}
