//
//  RecordView.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 11.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI

struct RecordView: View {
    let fVCDataBEXP: FVCDataBEXP
    let dateFormatter: DateFormatter
    
    init(fVCDataBEXP: FVCDataBEXP) {
        self.fVCDataBEXP = fVCDataBEXP
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
    }
    
    func standartEnumString(_ standart: standartEnum) -> String {
        switch standart {
        case .ECCS:
            return "ECCS"
        case .KNUDSON:
            return "KNUDSON"
        case .USA:
            return "USA"
        }
    }
    
    var body: some View {
        Form {
            Section {
                Text(fVCDataBEXP.date, formatter: dateFormatter)
            }
            
            Section(header: Text("Measurement")) {
                HStack {
                    Text("FVC")
                    Spacer()
                    Text("\(fVCDataBEXP.FVC, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEV05")
                    Spacer()
                    Text("\(fVCDataBEXP.FEV05, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEV1")
                    Spacer()
                    Text("\(fVCDataBEXP.FEV1, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEV1_FVC")
                    Spacer()
                    Text("\(fVCDataBEXP.FEV1_FVC, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEV3")
                    Spacer()
                    Text("\(fVCDataBEXP.FEV3, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEV6")
                    Spacer()
                    Text("\(fVCDataBEXP.FEV6, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("PEF")
                    Spacer()
                    Text("\(fVCDataBEXP.PEF, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
            }
            
            Section {
                HStack {
                    Text("FEF25")
                    Spacer()
                    Text("\(fVCDataBEXP.FEF25, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEF50")
                    Spacer()
                    Text("\(fVCDataBEXP.FEF50, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEF75")
                    Spacer()
                    Text("\(fVCDataBEXP.FEF75, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEF2575")
                    Spacer()
                    Text("\(fVCDataBEXP.FEF2575, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
            }
            
            Section {
                HStack {
                    Text("PEFT")
                    Spacer()
                    Text("\(fVCDataBEXP.PEFT)")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("EVOL")
                    Spacer()
                    Text("\(fVCDataBEXP.EVOL)")
                        .foregroundColor(.gray)
                }
            }
            
            Section(header: Text("Meta Data")) {
                HStack {
                    Text("Measure type")
                    Spacer()
                    Text("\(fVCDataBEXP.measureTypeName.rawValue)")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Standart type")
                    Spacer()
                    Text("\(standartEnumString(fVCDataBEXP.standartTypeName))")
                        .foregroundColor(.gray)
                }
            }
            
            Section(header: Text("Personal information")) {
                HStack {
                    Text("Age")
                    Spacer()
                    Text("\(fVCDataBEXP.age)")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Height")
                    Spacer()
                    Text("\(fVCDataBEXP.height)")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(fVCDataBEXP: FVCDataBEXP.example)
            .environment(\.locale, .init(identifier:"ru"))
    }
}
