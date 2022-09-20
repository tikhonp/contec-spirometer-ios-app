//
//  ProfileView.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 06.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var bleController: BLEController
    
    @Binding var isPresented: Bool
    @State private var saveUUID = UserDefaults.saveUUID
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        NavigationView {
            Form {
                #if DEBUG
                Section(header: Text("Personal information")) {
                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("", text: Binding(
                            get: { String(bleController.userParams.age) },
                            set: { bleController.userParams.age = Int($0) ?? 0 }
                        ))
                        .keyboardType(.numberPad)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("", text: Binding(
                            get: { String(bleController.userParams.height) },
                            set: { bleController.userParams.height = Int($0) ?? 0 }
                        ))
                        .keyboardType(.numberPad)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("", text: Binding(
                            get: { String(bleController.userParams.weight) },
                            set: { bleController.userParams.weight = Int($0) ?? 0 }
                        ))
                        .keyboardType(.numberPad)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                    }
                    Picker("Sex", selection: $bleController.userParams.sex ) {
                        Text("Male").tag(sexEnum.MALE)
                        Text("Female").tag(sexEnum.FEMALE)
                    }
                    Picker("Smoke", selection: $bleController.userParams.smoke ) {
                        Text("Yes").tag(UserParams.smokeEnum.SMOKE)
                        Text("No").tag(UserParams.smokeEnum.NOSMOKE)
                    }
                    Picker("Measurement mode", selection: $bleController.userParams.measureMode ) {
                        Text("All").tag(measureModeEnum.ALL)
                        Text("FVC").tag(measureModeEnum.FVC)
                        Text("MV").tag(measureModeEnum.MV)
                        Text("MVV").tag(measureModeEnum.MVV)
                        Text("VC").tag(measureModeEnum.VC)
                    }
                    Picker("Standart type", selection: $bleController.userParams.standart ) {
                        Text("ECCS").tag(standartEnum.ECCS)
                        Text("KNUDSON").tag(standartEnum.KNUDSON)
                        Text("USA").tag(standartEnum.USA)
                    }
                    Button("Save user params", action: bleController.setUserParams)
                }
                #endif
                
                Section(header: Text("Connected device")) {
                    Text(bleController.connectingPeripheral?.name ?? LocalizedStringKey("Unknown name").stringValue())
                    
                    if UserDefaults.saveUUID {
                        Button("Forget device", action: forgetDevice)
                    } else {
                        Button("Disconnect device", action: forgetDevice)
                    }
                }
                
                Section(footer: Text("Automatically connect to saved device after reboot")) {
                    Toggle("Save connection", isOn: $saveUUID)
                        .onChange(of: saveUUID) { value in
                            UserDefaults.saveUUID = value
                            
                            if value {
                                guard let peripheral = bleController.connectingPeripheral else {
                                    UserDefaults.savedSpirometrUUID = nil
                                    return
                                }
                                UserDefaults.savedSpirometrUUID = peripheral.identifier.uuidString
                            } else {
                                UserDefaults.savedSpirometrUUID = nil
                            }
                        }
                }
                
                if UserDefaults.medsengerContractId != nil && UserDefaults.medsengerAgentToken != nil {
                    Section(footer: Text("Delete Medsenger authorization details, you will not be able to send data to the service until you authorize again")) {
                        Button("Reset Medsenger credentials", action: bleController.resetMedsengerCredentials)
                    }
                }
                
                Section(header: Text("About"), footer: Text("(С) Medsenger Sync 2022")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion ?? LocalizedStringKey("Version not found").stringValue())
                    }
                }
            }
            .navigationBarTitle("Settings")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Close", action: { isPresented.toggle() })
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func forgetDevice() {
        UserDefaults.savedSpirometrUUID = nil
        bleController.disconnect()
        
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}
