//
//  SettingsButton.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsButton: View {
    @Environment(\.editMode) private var editMode

    @Binding var listSelection: ContentPanel?

    var body: some View {
        Button {
            listSelection = .settings
        } label: {
            Label("Settings", systemImage: "gear")
        }
        .buttonStyle(PlainToolbarButtonStyle())
        .accessibilityIdentifier("settings-button")
    }
}
