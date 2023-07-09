//
//  ProfilesSettingsTab.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfilesSettingsTab: View {
    @Binding var currentProfile: Profile?

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    @State private var selectedProfile: Profile?

    var body: some View {
        VStack {
            #if os(macOS)
            HSplitView {
                List(selection: $selectedProfile) {
                    ForEach(profiles, id: \.self) { profile in
                        Label {
                            profile.nameText
                        } icon: {
                            Image(systemName: profile == currentProfile ? "rhombus.fill" : "rhombus")
                                .foregroundColor(profile.tintColor)
                        }
                        .tag(profile as Profile?)
                    }
                }
                .listStyle(.sidebar)
                .frame(maxWidth: 160, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom, alignment: .leading) {
                    NewProfileButton().padding(12)
                }

                if let profile = selectedProfile {
                    ProfileSettings(
                        profile: profile,
                        currentProfile: $currentProfile,
                        deleteCallback: {
                            selectedProfile = currentProfile
                        }
                    )
                    .scrollContentBackground(.hidden)
                    .background(.background)
                }
            }
            .cornerRadius(8)
            #endif
        }
        .padding()
        .onAppear {
            selectedProfile = currentProfile
        }
    }
}
