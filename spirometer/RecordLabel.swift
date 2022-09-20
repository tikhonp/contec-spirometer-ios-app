//
//  RecordLabel.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 02.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI

struct RecordLabel: View {
    @EnvironmentObject var bleController: BLEController
    
    let fVCDataBEXP: FVCDataBEXPmodel
    let dateFormatter: DateFormatter
    
    init(fVCDataBEXP: FVCDataBEXPmodel) {
        self.fVCDataBEXP = fVCDataBEXP
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("FVC: \(fVCDataBEXP.fvc, specifier: "%.2f") L.")
                    .font(.headline)
                    .padding(.trailing, 1)
                if bleController.presentUploadToMedsenger {
                    Circle()
                        .foregroundColor(recordUploaded ? .green : .red)
                        .frame(width: 10, height: 10)
                }
            }
            Spacer()
            HStack {
                Image(systemName: "clock")
                Text("\(fVCDataBEXP.date!, formatter: dateFormatter)")
                Spacer()
            }
            .font(.caption)
        }
        .frame(height: 10)
        .padding()
    }
    
    private var recordUploaded: Bool {
        guard let lastUploadedDate = UserDefaults.lastUpladedDate else {
            return false
        }
        return fVCDataBEXP.date! < lastUploadedDate
    }
}

struct RecordLabel_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var fvcDataBexp: FVCDataBEXPmodel = {
        let context = persistence.container.viewContext
        return PersistenceController.Seed().getSingleFvcDataBexpItem(for: context)
    }()
    
    static var previews: some View {
        RecordLabel(fVCDataBEXP: fvcDataBexp)
            .environment(\.locale, .init(identifier:"ru"))
    }
}
