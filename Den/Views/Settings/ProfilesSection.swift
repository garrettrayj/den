//
//  ProfilesSection.swift
//  Den
//
//  Created by Garrett Johnson on 10/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct ProfilesSection: View {
    let profiles: FetchedResults<Profile>

    @Binding var currentProfileID: String?

    var body: some View {
        Section {
            ForEach(profiles) { profile in
                ProfilesSectionNavLink(profile: profile, currentProfileID: $currentProfileID)
            }
            NewProfileButton()
        } header: {
            Text("Profiles", comment: "Settings section header.")
        }
    }
}
