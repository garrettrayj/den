//
//  SettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?
    @Binding var uiStyle: UIUserInterfaceStyle
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var useInbuiltBrowser: Bool

    var body: some View {
        Form {
            ProfilesListSection(activeProfile: $activeProfile)
            FeedsSettingsSection()
            #if !targetEnvironment(macCatalyst)
            BrowserSettingsSection(profile: profile, useInbuiltBrowser: $useInbuiltBrowser)
            #endif
            AppearanceSettingsSection(uiStyle: $uiStyle)
            RefreshSettingsSection(
                autoRefreshEnabled: $autoRefreshEnabled,
                autoRefreshCooldown: $autoRefreshCooldown,
                backgroundRefreshEnabled: $backgroundRefreshEnabled
            )
            ResetSettingsSection(
                activeProfile: $activeProfile,
                appProfileID: $appProfileID,
                profile: profile
            )
            AboutSettingsSection()
        }
        .navigationTitle("Settings")
        .navigationDestination(for: SettingsPanel.self) { settingsPanel in
            Group {
                switch settingsPanel {
                case .profileSettings(let profile):
                    ProfileSettings(
                        profile: profile,
                        activeProfile: $activeProfile,
                        appProfileID: $appProfileID,
                        nameInput: profile.wrappedName,
                        tintSelection: profile.tint
                    )
                case .importFeeds:
                    ImportView(profile: profile)
                case .exportFeeds:
                    ExportView(profile: profile)
                case .security:
                    SecurityView(profile: profile)
                }
            }
            .background(GroupedBackground())
            .disabled(refreshManager.refreshing)
        }
    }
}
