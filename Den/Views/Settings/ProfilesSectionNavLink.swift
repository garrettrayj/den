//
//  ProfilesSectionNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 1/27/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct ProfilesSectionNavLink: View {
    @ObservedObject var profile: Profile
    
    @Binding var currentProfileID: String?
    
    var body: some View {
        NavigationLink {
            ProfileSettings(profile: profile)
                .navigationTitle(profile.nameText)
                .toolbarTitleDisplayMode(.inline)
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
}
