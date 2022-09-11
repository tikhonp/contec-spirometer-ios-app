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
    let dateFormatter: DateFormatter
    
    init(fVCDataBEXP: FVCDataBEXP) {
        self.fVCDataBEXP = fVCDataBEXP
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("FVC: \(fVCDataBEXP.FVC, specifier: "%.2f") L.")
                .font(.headline)
            Spacer()
            HStack {
                Label("EVOL: \(fVCDataBEXP.EVOL)", systemImage: "person.3")
                Spacer()
                Label("\(fVCDataBEXP.date, formatter: dateFormatter)", systemImage: "clock")
                    .padding(.trailing, 20)
            }
            .font(.caption)
        }
        .padding()
        .frame(width: .infinity, height: 30)
    }
}

struct RecordLabel_Previews: PreviewProvider {
    static var previews: some View {
        RecordLabel(fVCDataBEXP: FVCDataBEXP.example)
            .environment(\.locale, .init(identifier:"ru"))
    }
}
