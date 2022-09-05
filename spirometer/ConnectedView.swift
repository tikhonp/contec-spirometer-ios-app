//
//  ConnectedView.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 31.08.2022.
//

import SwiftUI

struct ConnectedView: View {
    @EnvironmentObject var bleController: BLEController
    
    var body: some View {
        ZStack {
            if bleController.resultDataController != nil {
                dataLoaded
            } else {
                loadingData
            }
        }
        .onAppear(perform: bleController.getData)
    }
    
    var dataLoaded: some View {
        ZStack {
            if bleController.resultDataController!.measuringCount == 0 {
                NavigationView {
                    Text("В вашем устройстве нет измерений.")
//                        .navigationBarTitle("Ваши измерения")
                        .toolbar {
                            Menu {
                                Button("Обновить данные", action: bleController.getData)
                                Button("Загрузить данные в Medsenger", action: uploadToMedsenger)
                                Button("Очистить память спирометра", action: bleController.deleteData)
                            } label: {
                                Label("", systemImage: "ellipsis.circle")
                            }
                        }
                }
            } else {
                NavigationView {
                    ScrollView {
                        ForEach(0..<bleController.resultDataController!.measuringCount, id: \.self) { i in
                            RecordLabel(fVCDataBEXP: bleController.resultDataController!.fVCDataBEXPs[i])
                        }
                        .navigationBarTitle("Ваши измерения")
                        .toolbar {
                            Menu {
                                Button("Обновить данные", action: bleController.getData)
                                Button("Загрузить данные в Medsenger", action: uploadToMedsenger)
                                Button("Очистить память спирометра", action: bleController.deleteData)
                            } label: {
                                Label("", systemImage: "ellipsis.circle")
                            }
                        }
                    }
                }
            }
        }
    }
    
    var loadingData: some View {
        VStack {
            Text("Загрузка данных со спирометра...")
            ProgressView(value: bleController.progress, total: 1)
        }
        .padding()
    }
    
    func uploadToMedsenger() {
        
    }
}

struct ConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
    }
}
