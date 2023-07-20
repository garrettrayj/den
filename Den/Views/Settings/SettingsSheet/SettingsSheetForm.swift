//
//  SettingsSheetForm.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsSheetForm: View {
    @Binding var currentProfileID: String?
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var feedRefreshTimeout: Int
    @Binding var useSystemBrowser: Bool
    @Binding var userColorScheme: UserColorScheme
    
    let profiles: FetchedResults<Profile>

    var body: some View {
        Form {
            ProfilesSettingsSection(currentProfileID: $currentProfileID, profiles: profiles)

            Section {
                UserColorSchemePicker(userColorScheme: $userColorScheme)
            } header: {
                Text("Appearance", comment: "Settings section header.")
            }

            #if os(iOS)
            Section {
                Toggle(isOn: $useSystemBrowser) {
                    Text("Use System Web Browser", comment: "Toggle label.")
                }
            } header: {
                Text("Links", comment: "Settings section header.")
            }
            #endif

            Section {
                Toggle(isOn: $backgroundRefreshEnabled) {
                    Text("In Background", comment: "Refresh option toggle label.")
                }

                VStack(alignment: .leading) {
                    FeedRefreshTimeoutLabel(feedRefreshTimeout: $feedRefreshTimeout)
                    FeedRefreshTimeoutSlider(feedRefreshTimeout: $feedRefreshTimeout)
                }
            } header: {
                Text("Refresh", comment: "Setting section header.")
            }

            Section {
                ClearCacheButton().buttonStyle(.borderless)
                ResetEverythingButton().buttonStyle(.plain)
            } header: {
                Text("Reset", comment: "Settings section header.")
            }

            SettingsAboutSection()
        }
        .navigationTitle(Text("Settings", comment: "Navigation title."))
    }
}
