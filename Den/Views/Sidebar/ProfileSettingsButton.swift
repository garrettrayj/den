//
//  ProfileSettingsButton.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfileSettingsButton: View {
    @Binding var showingProfileSettings: Bool

    var body: some View {
        Button {
            showingProfileSettings = true
        } label: {
            Label {
                Text("Profile Settings", comment: "Button label.")
            } icon: {
                Image(systemName: "gearshape")
            }
        }
        .accessibilityIdentifier("ShowProfileSettings")
    }
}
