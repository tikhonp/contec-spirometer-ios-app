//
//  ConnectedView.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 31.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI
import CoreData

struct ConnectedView: View {
    @EnvironmentObject var bleController: BLEController
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)], animation: .default)
    private var fvcDataBexps: FetchedResults<FVCDataBEXPmodel>
    
    @State private var showSettingsModal: Bool = false
    
    var body: some View {
        NavigationView {
            if bleController.fetchingDataWithSpirometer {
                loadingData
            }
            ZStack {
                if fvcDataBexps.isEmpty {
                    noMeasurements
                } else {
                    measurementsList
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: { showSettingsModal.toggle() }, label: {
                        Image(systemName: "person") })
                    Spacer()
                    Button(action: bleController.getData, label: { Image(systemName: "arrow.clockwise.circle") })
                    if fvcDataBexps.isEmpty {
                        Spacer()
                        Button("Upload to Medsenger", action: bleController.sendDataToMedsenger)
                        Spacer()
                        Button(action: bleController.deleteData, label:  {
                            Image(systemName: "trash") })
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showSettingsModal, content: { ProfileView() })
        .onAppear() {
            DispatchQueue.main.async { bleController.getData() }
        }
    }
    
    var noMeasurements: some View {
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
    }
    
    var measurementsList: some View {
        List {
            ForEach(fvcDataBexps) { fvcDataBexp in
                NavigationLink {
                    RecordView(fVCDataBEXP: fvcDataBexp)
                } label: {
                    RecordLabel(fVCDataBEXP: fvcDataBexp)
                }
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
            .environmentObject(BLEController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
