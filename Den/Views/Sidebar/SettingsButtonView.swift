//
//  SettingsButtonView.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SettingsButtonView: View {
    @Environment(\.editMode) private var editMode

    @Binding var apexSelection: ApexPanel?

    var body: some View {
        if editMode?.wrappedValue == .inactive {
            Button {
                apexSelection = .settings
            } label: {
                Label("Settings", systemImage: "gear")
            }
            .buttonStyle(PlainToolbarButtonStyle())
            .accessibilityIdentifier("settings-button")
        }
    }
}
