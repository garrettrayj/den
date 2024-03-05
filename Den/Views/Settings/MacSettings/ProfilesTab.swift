//
//  ProfilesTab.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfilesTab: View {
    @State private var selection: Profile?

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name, order: .forward),
        SortDescriptor(\.created, order: .forward)
    ])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        if profiles.isEmpty {
            ContentUnavailable {
                Label {
                    Text("No Profiles", comment: "Content unavailable title.")
                } icon: {
                    Image(systemName: "person")
                }
            } description: {
                Text(
                    "Use profiles to manage separate collections of feeds, pages and tags.",
                    comment: "No profiles guidance."
                )
            } actions: {
                NewProfileButton().buttonStyle(.borderedProminent).multilineTextAlignment(.leading)
            }
        } else {
            HStack(spacing: 0) {
                List(selection: $selection) {
                    ForEach(profiles, id: \.self) { profile in
                        profile.nameText.tag(profile as Profile?)
                    }
                }
                .frame(width: 180)
                .safeAreaInset(edge: .bottom, alignment: .leading) {
                    NewProfileButton().padding()
                }
                
                if let profile = selection {
                    ProfileSettings(profile: profile)
                } else {
                    HStack {
                        Spacer()
                        Text("No Selection", comment: "Content unavailable title.")
                            .font(.title)
                            .foregroundStyle(.tertiary)
                        Spacer()
                    }
                }
            }
        }
    }
}
