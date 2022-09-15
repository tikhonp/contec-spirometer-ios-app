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
    //    @Binding var isPresented: Bool
    @State private var saveUUID = UserDefaults.saveUUID
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        NavigationView {
            Form {
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
                }
                
                Section {
                    Toggle("Save Device", isOn: $saveUUID)
                        .onChange(of: saveUUID) { value in
                            UserDefaults.saveUUID = value
//                            UserDefaults.savedSpirometrUUID = nil
                        }
                    if UserDefaults.savedSpirometrUUID != nil {
                        Button("Forget Device") {
                            UserDefaults.savedSpirometrUUID = nil
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion ?? LocalizedStringKey("Version not found").stringValue())
                    }
                }
            }
            .navigationBarTitle("Settings")
            .toolbar {
                ToolbarItemGroup {
                    Button("Save", action: bleController.setUserParams)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
