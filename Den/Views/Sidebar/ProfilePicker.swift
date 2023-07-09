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
    @Binding var activeProfile: Profile?
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        Picker(selection: $activeProfile) {
            ForEach(profiles) { profile in
                profile.nameText
                    .tag(profile as Profile?)
                    .accessibilityIdentifier("profile-picker-option")
            }
        } label: {
            Text("Profile", comment: "Picker label.")
        }
        .accessibilityIdentifier("profile-picker")
    }
}
