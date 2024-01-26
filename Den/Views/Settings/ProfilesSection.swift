//
//  ProfilesSection.swift
//  Den
//
//  Created by Garrett Johnson on 10/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfilesSection: View {
    let profiles: [Profile]

    @Binding var currentProfileID: String?

    var body: some View {
        Section {
            ForEach(profiles) { profile in
                NavigationLink {
                    ProfileSettings(profile: profile).navigationTitle(profile.nameText)
                } label: {
                    Label {
                        profile.nameText
                    } icon: {
                        Image(systemName: "rhombus")
                            .symbolVariant(profile.id?.uuidString == currentProfileID ? .fill : .none)
                    }
                }
                .accessibilityIdentifier("ProfileSettings")
            }
            NewProfileButton()
        } header: {
            Text("Profiles", comment: "Settings section header.")
        }
    }
}
