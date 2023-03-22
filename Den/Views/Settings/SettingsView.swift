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
    @Binding var activeProfile: Profile?
    @Binding var sceneProfileID: String?
    @Binding var appProfileID: String?
    @Binding var uiStyle: UIUserInterfaceStyle
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var useInbuiltBrowser: Bool

    let profile: Profile

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        Form {
            Group {
                ProfilesListSection(sceneProfileID: $sceneProfileID)
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
                    sceneProfileID: $sceneProfileID,
                    appProfileID: $appProfileID,
                    profile: profile
                )
                AboutSettingsSection()
            }

        }
        .navigationTitle("Settings")
    }
}
