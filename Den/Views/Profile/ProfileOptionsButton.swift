//
//  ProfileOptionsButton.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfileOptionsButton: View {
    @Binding var showingProfileOptions: Bool

    var body: some View {
        Button {
            showingProfileOptions = true
        } label: {
            Label {
                Text("Profile Options", comment: "Button label.")
            } icon: {
                Image(systemName: "gearshape")
            }
        }
        .accessibilityIdentifier("ShowProfileOptions")
    }
}
