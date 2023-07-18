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
            if currentProfileID == nil {
                Text("None", comment: "Profile picker placeholder option.").tag(nil as String?)
            }
            
            ForEach(profiles) { profile in
                ProfileLabel(profile: profile, currentProfileID: $currentProfileID)
                    .accessibilityIdentifier("ProfileOption")
                    .tag(profile.id?.uuidString)
            }
        } label: {
            Text("Profile", comment: "Picker label.")
        }
        .accessibilityIdentifier("ProfilePicker")
    }
}
