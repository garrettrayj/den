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
    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var feedRefreshTimeout: Double
    @Binding var useSystemBrowser: Bool
    @Binding var userColorScheme: UserColorScheme

    var body: some View {
        Form {
            ProfilesSettingsSection(activeProfile: $activeProfile, appProfileID: $appProfileID)

            Section {
                ImportButton(activeProfile: $activeProfile)
                ExportButton(activeProfile: $activeProfile)
            } header: {
                Text("OPML")
            }

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
                ClearCacheButton(activeProfile: $activeProfile).buttonStyle(.borderless)

                ResetEverythingButton(
                    activeProfile: $activeProfile,
                    appProfileID: $appProfileID
                )
                .buttonStyle(.plain)
            } header: {
                Text("Reset", comment: "Settings section header.")
            }

            SettingsAboutSection()
        }
        .navigationTitle(Text("Settings", comment: "Navigation title."))
    }
}
