//
//  ConnectedView.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 31.08.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI
import CoreData
import Sentry

struct MainView: View {
    
    // MARK: - View varibles
    
    @EnvironmentObject private var bleController: BLEController
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)], animation: .default)
    private var fvcDataBexps: FetchedResults<FVCDataBEXPmodel>
    
    @State private var showSettingsModal: Bool = false
    @State private var isPresentedDeviceList: Bool = false
    
    // MARK: - View body
    
    var body: some View {
        NavigationView {
            VStack {
                progressView
                inlineAlerts
                if fvcDataBexps.isEmpty {
                    noMeasurements
                } else {
                    measurementsList
                }
            }
            .transition(.slide)
            .animation(.easeInOut(duration: 0.3), value: bleController.progress)
            .animation(.easeInOut(duration: 0.3), value: bleController.showBluetoothIsOffWarning)
            .animation(.easeInOut(duration: 0.3), value: bleController.fetchingDataWithSpirometer)
            .animation(.easeInOut(duration: 0.3), value: bleController.showSelectDevicesInfo)
            .navigationBarTitle { navigationBarTitle }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if bleController.isBluetoothOn {
                        if !bleController.isConnected {
                            Button {
                                isPresentedDeviceList.toggle()
                            } label: {
                                HStack {
                                    if #available(iOS 15.0, *) {
                                        Text("Devices")
                                            .badge(bleController.devices.count)
                                            .id(UUID())
                                    } else {
                                        Text("Devices")
                                            .id(UUID())
                                        // TODO: Add badge on earlier versions
                                    }
                                }
                            }
                        } else {
                            Button(action: { showSettingsModal.toggle() }, label: {
                                Image(systemName: "gearshape") })
                            .id(UUID())
                        }
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    if !fvcDataBexps.isEmpty && bleController.presentUploadToMedsenger {
                        HStack {
                            if bleController.sendingToMedsengerStatus != 0 {
                                ProgressView()
                            }
                            Button("Upload to Medsenger", action: {
                                HapticFeedbackController.shared.play(.heavy)
                                bleController.sendDataToMedsenger()
                            })
                        }
                    }
                    Spacer()
                    if bleController.isConnected && !bleController.fetchingDataWithSpirometer {
                        Button(action: {
                            HapticFeedbackController.shared.play(.medium)
                            bleController.getData()
                        }, label: { Image(systemName: "arrow.clockwise.circle") })
                    }
                    if !(!fvcDataBexps.isEmpty && bleController.presentUploadToMedsenger) {
                        Spacer()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showSettingsModal, content: { ProfileView(isPresented: $showSettingsModal) })
        .sheet(isPresented: $isPresentedDeviceList, content: { ConnectView(isPresented: $isPresentedDeviceList) })
        .onReceive(bleController.$isConnected) { flag in
            if flag { isPresentedDeviceList = false }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.bleController.discover()
            }
        }
    }
    
    // MARK: - Additional Views
    
    private var navigationBarTitle: some View {
        HStack {
            if !bleController.isConnected || !bleController.isBluetoothOn || bleController.fetchingDataWithSpirometer {
                ProgressView()
                    .padding(.trailing, 1)
            }
            Text(bleController.navigationBarTitleStatus)
        }
    }
    
    private var progressView: some View {
        ZStack {
            if bleController.fetchingDataWithSpirometer {
                ProgressView(value: bleController.progress, total: 1)
                    .padding()
                Spacer()
            }
        }
    }
    
    private var inlineAlerts: some View {
        ZStack {
            if bleController.showBluetoothIsOffWarning {
                Text("To connect the spirometer, turn on the bluetooth and give the app permission to use it.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            if bleController.showSelectDevicesInfo {
                HStack(alignment: .top) {
                    Spacer()
                    Text("Click here and select the spirometer to connect.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Spacer()
                    Text("👆")
                }
                .padding()
            }
        }
    }
    
    private var noMeasurements: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("No measurements recorded")
                .font(.title2)
                .fontWeight(.bold)
            Text("Take measurements with a spirometer so they appear here.")
                .font(.body)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
                .padding(.leading, 40)
                .padding(.trailing, 40)
            Spacer()
        }
    }
    
    private var measurementsList: some View {
        List {
            ForEach(fvcDataBexps) { fvcDataBexp in
                NavigationLink {
                    RecordView(fVCDataBEXP: fvcDataBexp)
                } label: {
                    RecordLabel(fVCDataBEXP: fvcDataBexp)
                }
            }
            .onDelete(perform: deleteFVCDataBEXPmodels)
        }
    }

    // MARK: - private functions
    
    private func deleteFVCDataBEXPmodels(offsets: IndexSet) {
        withAnimation {
            offsets.map { fvcDataBexps[$0] }.forEach(viewContext.delete)
            saveCoreData()
        }
    }

    private func saveCoreData() {
        do {
            try viewContext.save()
        } catch {
            print("Core Data failed to save model: \(error.localizedDescription)")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(BLEController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
