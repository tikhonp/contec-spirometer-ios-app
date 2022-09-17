//
//  View+NavigationBarTitle.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 17.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import SwiftUI

extension View {
    func navigationBarTitle<Content>(
        @ViewBuilder content: () -> Content
    ) -> some View where Content : View {
        self.toolbar {
            ToolbarItem(placement: .principal, content: content)
        }
    }
}
