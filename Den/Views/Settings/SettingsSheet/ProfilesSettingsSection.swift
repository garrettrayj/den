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
    @Binding var currentProfileID: String?

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        Section {
            ForEach(profiles) { profile in
                NavigationLink {
                    ProfileSettings(profile: profile)
                        .navigationTitle(Text("Profile Settings", comment: "Navigation title."))
                } label: {
                    ProfileLabel(profile: profile, currentProfileID: $currentProfileID)
                }
            }
            NewProfileButton()
        } header: {
            Text("Profiles", comment: "Settings section header.")
        }
    }
}
