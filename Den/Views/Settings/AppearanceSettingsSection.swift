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
    @Binding var uiStyle: UIUserInterfaceStyle

    var body: some View {
        Section(header: Text("Appearance")) {
            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Theme").modifier(FormRowModifier())
                Spacer()
                UIStylePickerView(uiStyle: $uiStyle).labelsHidden().scaledToFit()
            }
            #else
            UIStylePickerView(uiStyle: $uiStyle)
            #endif
        }
    }
}
