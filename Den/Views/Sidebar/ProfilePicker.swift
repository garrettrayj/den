//
//  ProfilePicker.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfilePicker: View {
    @Binding var currentProfileID: String?
    
    let profiles: FetchedResults<Profile>

    var body: some View {
        Picker(selection: $currentProfileID) {
            ForEach(profiles) { profile in
                ProfileLabel(profile: profile, currentProfileID: $currentProfileID)
                    .tag(profile.id?.uuidString as String?)
                    .accessibilityIdentifier("ProfileOption")
            }
        } label: {
            Text("Profile", comment: "Picker label.")
        }
    }
}
