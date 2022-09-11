//
//  ConnectedView.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 31.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
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
                    VStack(alignment: .center) {
                        Text("No measurements recorded")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Take measurements with a spirometer so they appear here.")
                            .font(.body)
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 40)
                            .padding(.trailing, 40)
                    }
                } else {
                    measurementsList
                }
            }
            .toolbar { ToolbarItemGroup(placement: .bottomBar) {
                Button(action: { showSettingsModal.toggle() }, label: {
                    Image(systemName: "person") })
                Spacer()
                Button(action: bleController.getData, label: { Image(systemName: "arrow.clockwise.circle") })
                if bleController.resultDataController!.measuringCount != 0 {
                    Spacer()
                    Button("Upload to Medsenger", action: bleController.sendDataToMedsenger)
                    Spacer()
                    Button(action: bleController.deleteData, label:  {
                        Image(systemName: "trash") })
                } } }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showSettingsModal, content: { ProfileView() })
        
    }
    
    var measurementsList: some View {
        List {
            ForEach(0..<bleController.resultDataController!.measuringCount, id: \.self) { i in
                NavigationLink(destination: RecordView(fVCDataBEXP: bleController.resultDataController!.fVCDataBEXPs[i]), label: {
                    RecordLabel(fVCDataBEXP: bleController.resultDataController!.fVCDataBEXPs[i])
                })
                
            }
            .navigationTitle("Your measurements")
        }
    }
    
    var loadingData: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("Downloading data from a spirometer")
                .font(.title2)
                .fontWeight(.bold)
            Text("Do not turn off the device until the end.")
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
