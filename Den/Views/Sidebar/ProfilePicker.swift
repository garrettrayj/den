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

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name, order: .forward),
        SortDescriptor(\.created, order: .forward)
    ])
    private var profiles: FetchedResults<Profile>

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
    }
}
