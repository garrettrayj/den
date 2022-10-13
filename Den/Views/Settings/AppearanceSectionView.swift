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
    @Binding var showScrollIndicators: Bool

    var body: some View {
        Section(header: Text("Appearance")) {
            Picker(selection: $uiStyle) {
                Text("System").tag(UIUserInterfaceStyle.unspecified)
                Text("Light").tag(UIUserInterfaceStyle.light)
                Text("Dark").tag(UIUserInterfaceStyle.dark)
            } label: {
                Text("Theme")
            }.modifier(FormRowModifier())

            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Show Scrollbar")
                Spacer()
                Toggle("Show Scrollbar", isOn: $showScrollIndicators).labelsHidden()
            }.modifier(FormRowModifier())
            #else
            Toggle(isOn: $showScrollIndicators) {
                Text("Show Scrollbar")
            }
            #endif
        }
    }
}
