//
//  ProfilePicker.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct ProfilePicker: View {
    @Binding var currentProfileID: String?
    @Binding var lastProfileID: String?

    let profiles: [Profile]

    var body: some View {
        Picker(selection: $currentProfileID) {
            ForEach(profiles) { profile in
                profile.nameText
                    .tag(profile.id?.uuidString as String?)
                    .accessibilityIdentifier("ProfileOption")
            }
        } label: {
            Text("Profile", comment: "Picker label.")
        }
        .onChange(of: currentProfileID) {
            lastProfileID = currentProfileID
        }
    }
}
