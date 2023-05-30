//
//  AppearanceSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AppearanceSettingsSection: View {
    @ObservedObject var profile: Profile

    @Binding var uiStyle: UIUserInterfaceStyle

    var body: some View {
        Section {
            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Theme", comment: "Picker label").modifier(FormRowModifier())
                Spacer()
                UIStylePickerView(uiStyle: $uiStyle).labelsHidden().scaledToFit()
            }
            #else
            UIStylePickerView(uiStyle: $uiStyle)
            #endif
        } header: {
            Text("Appearance", comment: "Settings section header")
        }
        .modifier(ListRowModifier())
    }
}
