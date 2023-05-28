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
    @Binding var useSystemBrowser: Bool

    var body: some View {
        Form {
            ProfilesListSection(activeProfile: $activeProfile)
            AppearanceSettingsSection(profile: profile, uiStyle: $uiStyle)
            #if !targetEnvironment(macCatalyst)
            BrowserSettingsSection(useSystemBrowser: $useSystemBrowser)
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
        .navigationTitle(Text("Settings"))
    }
}
