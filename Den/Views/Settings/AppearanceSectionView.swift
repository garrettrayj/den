//
//  AppearanceSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct AppearanceSectionView: View {
    @AppStorage("UIStyle") private var uiStyle = UIUserInterfaceStyle.unspecified

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
        .modifier(SectionHeaderModifier())
        .onChange(of: uiStyle, perform: { _ in
            ThemeManager.applyStyle()
        })
    }

    private var themeSelectionLabel: some View {
        Label("Theme", systemImage: "paintbrush").lineLimit(1)
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
