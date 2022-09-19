//
//  RecordView.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 11.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI
import Charts

struct ValueRowView: View {
    let key: String
    let value: Text
    
    var body: some View {
        HStack {
            Text(key)
            Spacer()
            value
                .foregroundColor(.gray)
        }
    }
}

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
                HStack {
                    Image(systemName: "clock")
                    Text(fVCDataBEXP.date!, formatter: dateFormatter)
                }
            }
            
            #if DEBUG
            if #available(iOS 16.0, *) {
                Section(header: Text("Speeds")) {
                    Chart {
                        ForEach(Array(fVCDataBEXP.speedsArray!.enumerated()), id: \.offset) { index, element in
                            LineMark(
                                x: .value("Month", index),
                                y: .value("Hours of Sunshine", element)
                            )
                        }
                    }
                    .frame(height: 200)
                }
                
                
                Section(header: Text("Volumes")) {
                    Chart {
                        ForEach(Array(fVCDataBEXP.volumesArray!.enumerated()), id: \.offset) { index, element in
                            LineMark(
                                x: .value("Month", index),
                                y: .value("Hours of Sunshine", element)
                            )
                        }
                    }
                    .frame(height: 200)
                }
                
                
                Section(header: Text("Times")) {
                    Chart {
                        ForEach(Array(fVCDataBEXP.timesArray!.enumerated()), id: \.offset) { index, element in
                            LineMark(
                                x: .value("Month", index),
                                y: .value("Hours of Sunshine", element)
                            )
                        }
                    }
                    .frame(height: 200)
                }
                
            } else {
                // Fallback on earlier versions
            }
            #endif
            
            Section(header: Text("Measurement")) {
                ValueRowView(key: "FVC", value: Text("\(fVCDataBEXP.fvc, specifier: "%.2f")"))
                ValueRowView(key: "FEV05", value: Text("\(fVCDataBEXP.fev05, specifier: "%.2f")"))
                ValueRowView(key: "FEV1", value: Text("\(fVCDataBEXP.fev1, specifier: "%.2f")"))
                ValueRowView(key: "FEV1_FVC", value: Text("\(fVCDataBEXP.fev1_fvc, specifier: "%.2f")"))
                ValueRowView(key: "FEV3", value: Text("\(fVCDataBEXP.fev3, specifier: "%.2f")"))
                ValueRowView(key: "FEV6", value: Text("\(fVCDataBEXP.fev6, specifier: "%.2f")"))
                ValueRowView(key: "PEF", value: Text("\(fVCDataBEXP.pef, specifier: "%.2f")"))
            }
            
            Section {
                ValueRowView(key: "FEF25", value: Text("\(fVCDataBEXP.fef25, specifier: "%.2f")"))
                ValueRowView(key: "FEF50", value: Text("\(fVCDataBEXP.fef50, specifier: "%.2f")"))
                ValueRowView(key: "FEF75", value: Text("\(fVCDataBEXP.fef75, specifier: "%.2f")"))
                ValueRowView(key: "FEF2575", value: Text("\(fVCDataBEXP.fef2575, specifier: "%.2f")"))
            }
            
            Section {
                ValueRowView(key: "PEFT", value: Text("\(fVCDataBEXP.peft, specifier: "%.2f")"))
                ValueRowView(key: "EVOL", value: Text("\(fVCDataBEXP.evol, specifier: "%.2f")"))
            }
            
            Section(header: Text("Meta Data")) {
                ValueRowView(key: "Measure type", value: Text("\(measureTypeString(fVCDataBEXP.measureType))"))
                ValueRowView(key: "Standart type", value: Text("\(standartTypeString(fVCDataBEXP.standartType))"))
            }
            
            Section(header: Text("Personal information")) {
                ValueRowView(key: "Age", value:  Text("\(fVCDataBEXP.age)"))
                ValueRowView(key: "Height", value: Text("\(fVCDataBEXP.height)"))
                ValueRowView(key: "Sex", value: Text("\(fVCDataBEXP.gender == 0 ? LocalizedStringKey("Male").stringValue() : LocalizedStringKey("Female").stringValue())"))
            }
        }
        .navigationBarTitle("Measurement")
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
