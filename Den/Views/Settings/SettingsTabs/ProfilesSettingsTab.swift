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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    @State private var selectedProfile: Profile?

    var body: some View {
        VStack {
            #if os(macOS)
            HSplitView {
                List(selection: $selectedProfile) {
                    ForEach(profiles, id: \.self) { profile in
                        ProfileLabel(profile: profile, currentProfileID: .constant(nil))
                            .tag(profile as Profile?)
                            .contextMenu(ContextMenu(menuItems: {
                                DeleteProfileButton(
                                    profile: profile,
                                    callback: { selectedProfile = profiles.first },
                                    showAlert: false
                                )
                            }))
                    }
                }
                .listStyle(.sidebar)
                .frame(maxWidth: 160, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom, alignment: .leading) {
                    NewProfileButton().padding(12)
                }

                if let profile = selectedProfile {
                    ProfileSettings(profile: profile)
                        .scrollContentBackground(.hidden)
                        .background(.background)
                } else {
                    SplashNote(title: Text("Select a Profile", comment: "Profile settings tab guidance."))
                }
            }
            .cornerRadius(8)
            #endif
        }
        .padding()
        .onAppear {
            selectedProfile = profiles.first
        }
    }
}
