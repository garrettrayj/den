//
//  ProfilesSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ProfilesSectionView: View {
    @EnvironmentObject private var profileManager: ProfileManager

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        Section {
            ForEach(profiles) { profile in
                NavigationLink {
                    ProfileView(profile: profile)
                } label: {
                    Label(
                        profile.displayName,
                        systemImage: profile == profileManager.activeProfile ? "hexagon.fill" : "hexagon"
                    )
                }
                .modifier(FormRowModifier())
                .accessibilityIdentifier("profile-button")
            }

            Button(action: profileManager.addProfile) {
                Label("Add Profile", systemImage: "plus")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("add-profile-button")
        } header: {
            Text("Profiles")
        }.modifier(SectionHeaderModifier())
    }
}
