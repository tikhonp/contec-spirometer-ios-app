//
//  MainView.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 31.08.2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var rootViewModel: RootViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
