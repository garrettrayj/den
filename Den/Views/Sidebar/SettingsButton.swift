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
    @Binding var showingSettings: Bool

    var body: some View {
        Button {
            showingSettings = true
        } label: {
            Label {
                Text("Settings", comment: "Button label.")
            } icon: {
                Image(systemName: "gear")
            }
        }
        .accessibilityIdentifier("ShowSettings")
    }
}
