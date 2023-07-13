//
//  ProfilesSettingsSection.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfilesSettingsSection: View {
    @Binding var currentProfile: Profile?

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        Section {
            ForEach(profiles) { profile in
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
            NewProfileButton()
        } header: {
            Text("Profiles", comment: "Settings section header.")
        }
    }
}
