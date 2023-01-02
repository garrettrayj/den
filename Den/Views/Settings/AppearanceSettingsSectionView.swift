//
//  AppearanceSettingsSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AppearanceSettingsSectionView: View {
    @Binding var uiStyle: UIUserInterfaceStyle

    var body: some View {
        Section(header: Text("Appearance")) {
            Picker(selection: $uiStyle) {
                Text("System").tag(UIUserInterfaceStyle.unspecified)
                Text("Light").tag(UIUserInterfaceStyle.light)
                Text("Dark").tag(UIUserInterfaceStyle.dark)
            } label: {
                Text("Theme")
            }.modifier(FormRowModifier())
        }
    }
}
