//
//  SettingsList.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsList: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var useSystemBrowser: Bool
    @Binding var userColorScheme: UserColorScheme

    var body: some View {
        Form {
            ProfilesSettingsListSection(activeProfile: $activeProfile)
            AppearanceSettingsListSection(userColorScheme: $userColorScheme)
            #if os(iOS)
            BrowserSettingsListSection(useSystemBrowser: $useSystemBrowser)
            #endif
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
        .navigationTitle(Text("Settings", comment: "Navigation title."))
    }
}
