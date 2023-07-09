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

    @Binding var activeProfile: Profile?

    var body: some View {
        NavigationLink {
            ProfileSettings(
                profile: profile,
                activeProfile: $activeProfile,
                deleteCallback: {}
            )
            .navigationTitle(Text("Profile Settings", comment: "Navigation title."))
        } label: {
            Label {
                profile.nameText
            } icon: {
                Image(systemName: profile == activeProfile ? "rhombus.fill" : "rhombus")
                    .foregroundColor(profile.tintColor)
            }
        }
    }
}
