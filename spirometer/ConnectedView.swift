//
//  ConnectedView.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 31.08.2022.
//

import SwiftUI

struct ConnectedView: View {
    @EnvironmentObject var bleController: BLEController
    
    @State private var showSettingsModal: Bool = false
    
    var body: some View {
        ZStack {
            if bleController.resultDataController != nil {
                dataLoaded
            } else {
                loadingData
            }
        }
        .onAppear() {
            DispatchQueue.main.async {
                bleController.getData()
            }
        }
    }
    
    var dataLoaded: some View {
        NavigationView {
            ZStack {
                if bleController.resultDataController!.measuringCount == 0 {
                    Text("В вашем устройстве нет измерений.")
                    
                } else {
                    measurementsList
                }
            }
            .toolbar { Button(action: bleController.getData, label: { Image(systemName: "arrow.clockwise.circle") }) }
            .toolbar { ToolbarItemGroup(placement: .bottomBar) {
                Button(action: { showSettingsModal.toggle() }, label: {
                    Image(systemName: "person") })
                Spacer()
                if bleController.resultDataController!.measuringCount != 0 {
                    Button("Загрузить в Medsenger", action: bleController.sendDataToMedsenger)
                    Spacer()
                    Button(action: bleController.deleteData, label:  {
                        Image(systemName: "trash") })
                } } }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showSettingsModal, content: { ProfileView() })
        
    }
    
    var measurementsList: some View {
        ScrollView {
            ForEach(0..<bleController.resultDataController!.measuringCount, id: \.self) { i in
                RecordLabel(fVCDataBEXP: bleController.resultDataController!.fVCDataBEXPs[i])
            }
            .navigationTitle("Ваши измерения")
        }
    }
    
    var loadingData: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("Загрузка данных со спирометра")
                .font(.title2)
                .fontWeight(.bold)
            Text("Не выключайте устройство до завершения")
                .font(.body)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
                .padding(.leading, 40)
                .padding(.trailing, 40)
            ProgressView(value: bleController.progress, total: 1)
                .padding()
            Spacer()
        }
    }
}

struct ConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
    }
}
