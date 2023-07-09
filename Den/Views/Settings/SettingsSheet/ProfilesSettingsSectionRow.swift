//
//  ProfilesSettingsSectionRow.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfilesSettingsSectionRow: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var profile: Profile

    @Binding var currentProfile: Profile?

    var body: some View {
        NavigationLink {
            ProfileSettings(
                profile: profile,
                currentProfile: $currentProfile,
                deleteCallback: {}
            )
            .navigationTitle(Text("Profile Settings", comment: "Navigation title."))
        } label: {
            Label {
                profile.nameText
            } icon: {
                Image(systemName: profile == currentProfile ? "rhombus.fill" : "rhombus")
                    .foregroundColor(profile.tintColor)
            }
        }
    }
}
