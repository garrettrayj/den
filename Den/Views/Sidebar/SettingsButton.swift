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
    @SceneStorage("ShowingSettings") private var showingSettings = false

    var body: some View {        
        Button {
            showingSettings = true
        } label: {
            Label {
                Text("Settings", comment: "Button label.")
            } icon: {
                Image(systemName: "gearshape")
            }
        }
        .accessibilityIdentifier("ShowSettings")
    }
}
