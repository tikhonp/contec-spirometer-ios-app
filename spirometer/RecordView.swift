//
//  RecordView.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 11.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI

struct RecordView: View {
    let fVCDataBEXP: FVCDataBEXPmodel
    let dateFormatter: DateFormatter
    
    init(fVCDataBEXP: FVCDataBEXPmodel) {
        self.fVCDataBEXP = fVCDataBEXP
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
    }
    
    private func standartTypeString(_ standartType: Int64) -> String {
        switch (standartType) {
        case 1:
            return "ECCS"
        case 2:
            return "KNUDSON"
        case 3:
            return "USA"
        default:
            return "Unknown"
        }
    }
    
    private func measureTypeString(_ measureType: Int64) -> String {
        switch (measureType)  {
        case 0:
            return "ALL"
        case 1:
            return "FVC"
        case 2:
            return "VC"
        case 3:
            return "MVV"
        case 4:
            return "MV"
        default:
            return "Unknown"
        }
    }
    
    var body: some View {
        Form {
            Section {
                Text(fVCDataBEXP.date!, formatter: dateFormatter)
            }
            
            Section(header: Text("Measurement")) {
                HStack {
                    Text("FVC")
                    Spacer()
                    Text("\(fVCDataBEXP.fvc, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEV05")
                    Spacer()
                    Text("\(fVCDataBEXP.fev05, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEV1")
                    Spacer()
                    Text("\(fVCDataBEXP.fev1, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEV1_FVC")
                    Spacer()
                    Text("\(fVCDataBEXP.fev1_fvc, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEV3")
                    Spacer()
                    Text("\(fVCDataBEXP.fev3, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEV6")
                    Spacer()
                    Text("\(fVCDataBEXP.fev6, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("PEF")
                    Spacer()
                    Text("\(fVCDataBEXP.pef, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
            }
            
            Section {
                HStack {
                    Text("FEF25")
                    Spacer()
                    Text("\(fVCDataBEXP.fef25, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEF50")
                    Spacer()
                    Text("\(fVCDataBEXP.fef50, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEF75")
                    Spacer()
                    Text("\(fVCDataBEXP.fef75, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("FEF2575")
                    Spacer()
                    Text("\(fVCDataBEXP.fef2575, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
            }
            
            Section {
                HStack {
                    Text("PEFT")
                    Spacer()
                    Text("\(fVCDataBEXP.peft)")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("EVOL")
                    Spacer()
                    Text("\(fVCDataBEXP.evol)")
                        .foregroundColor(.gray)
                }
            }
            
            Section(header: Text("Meta Data")) {
                HStack {
                    Text("Measure type")
                    Spacer()
                    Text("\(measureTypeString(fVCDataBEXP.measureType))")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Standart type")
                    Spacer()
                    Text("\(standartTypeString(fVCDataBEXP.standartType))")
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
                HStack {
                    Text("Sex")
                    Spacer()
                    Text("\(fVCDataBEXP.gender == 0 ? "Male" : "Female")")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var fvcDataBexp: FVCDataBEXPmodel = {
        let context = persistence.container.viewContext
        return PersistenceController.Seed().getSingleFvcDataBexpItem(for: context)
    }()
    
    static var previews: some View {
        RecordView(fVCDataBEXP: fvcDataBexp)
            .environment(\.locale, .init(identifier:"ru"))
    }
}
