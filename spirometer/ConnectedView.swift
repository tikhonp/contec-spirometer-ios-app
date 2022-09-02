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
        NavigationView {
            ScrollView {
                HStack {
                    Text("Выберите врача, к которому привязать колонку.")
                    Spacer()
                }
                .padding()
                
                ForEach(0..<bleController.resultDataController!.measuringCount!) { i in
                    Text(String(bleController.resultDataController!.fVCDataBEXP[i].EVOL))
                }
            }
        }
        .refreshable {
            bleController.getData()
        }
    }
    
    var loadingData: some View {
        VStack {
            Text("Загрузка данных со спирометра...")
            ProgressView(value: bleController.progress)
        }
        .padding()
    }
}

struct ConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
    }
}
