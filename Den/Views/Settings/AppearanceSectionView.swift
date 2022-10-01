//
//  AppearanceSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct AppearanceSectionView: View {
    @Binding var uiStyle: UIUserInterfaceStyle

    var body: some View {
        Section(header: Text("Appearance")) {
            #if targetEnvironment(macCatalyst)
            HStack {
                themeSelectionLabel
                Spacer()
                themeSelectionPicker
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                    .modifier(FormRowModifier())
            }.modifier(FormRowModifier())
            #else
            themeSelectionPicker
            #endif
        }
    }

    private var themeSelectionLabel: some View {
        Text("Theme")
    }

    private var themeSelectionPicker: some View {
        Picker(selection: $uiStyle) {
            Text("System").tag(UIUserInterfaceStyle.unspecified)
            Text("Light").tag(UIUserInterfaceStyle.light)
            Text("Dark").tag(UIUserInterfaceStyle.dark)
        } label: {
            themeSelectionLabel
        }
    }
}
