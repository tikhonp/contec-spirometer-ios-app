//
//  ProfileView.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 06.09.2022.
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
                Section(header: Text("Личные данные")) {
                    HStack {
                        Text("Возраст")
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
                        Text("Рост")
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
                        Text("Вес")
                        Spacer()
                        TextField("", text: Binding(
                            get: { String(bleController.userParams.weight) },
                            set: { bleController.userParams.weight = Int($0) ?? 0 }
                        ))
                        .keyboardType(.numberPad)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                    }
                    Picker("Пол", selection: $bleController.userParams.sex ) {
                        Text("Мужской").tag(sexEnum.MALE)
                        Text("Женский").tag(sexEnum.FEMALE)
                    }
                    Picker("Курение", selection: $bleController.userParams.smoke ) {
                        Text("Да").tag(UserParams.smokeEnum.SMOKE)
                        Text("Нет").tag(UserParams.smokeEnum.NOSMOKE)
                    }
                    Picker("Режим измерения", selection: $bleController.userParams.measureMode ) {
                        Text("Все").tag(measureModeEnum.ALL)
                        Text("FVC").tag(measureModeEnum.FVC)
                        Text("MV").tag(measureModeEnum.MV)
                        Text("MVV").tag(measureModeEnum.MVV)
                        Text("VC").tag(measureModeEnum.VC)
                    }
                    Picker("Режим измерения", selection: $bleController.userParams.standart ) {
                        Text("ECCS").tag(standartEnum.ECCS)
                        Text("KNUDSON").tag(standartEnum.KNUDSON)
                        Text("USA").tag(standartEnum.USA)
                    }
                }
                
                Section {
                    Toggle("Запоминать устройство", isOn: $saveUUID)
                        .onChange(of: saveUUID) { value in
                            UserDefaults.saveUUID = value
//                            UserDefaults.savedSpirometrUUID = nil
                        }
                    if UserDefaults.savedSpirometrUUID != nil {
                        Button("Забыть устройство") {
                            UserDefaults.savedSpirometrUUID = nil
                        }
                    }
                }
                
                Section(header: Text("О приложении")) {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text(appVersion ?? "Версия не найдена")
                    }
                }
            }
            .navigationBarTitle("Настройки")
            .toolbar {
                ToolbarItemGroup {
                    Button("Cохранить", action: bleController.setUserParams)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: bleController.initilizeUserParams)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
