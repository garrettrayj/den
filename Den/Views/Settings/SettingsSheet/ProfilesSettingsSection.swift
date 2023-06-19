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
    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        Section {
            ForEach(profiles) { profile in
                ProfilesSettingsSectionRow(
                    profile: profile,
                    appProfileID: $appProfileID,
                    activeProfile: $activeProfile
                )
            }
            NewProfileButton()
        } header: {
            Text("Profiles", comment: "Settings section header.")
        }
    }
}
