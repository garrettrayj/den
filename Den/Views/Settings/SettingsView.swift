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
    @Binding var contentSizeCategory: UIContentSizeCategory
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var useInbuiltBrowser: Bool

    let profile: Profile

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    var body: some View {
        Form {
            ProfilesSettingsSectionView(sceneProfileID: $sceneProfileID)
            FeedsSettingsSectionView()
            #if !targetEnvironment(macCatalyst)
            BrowserSettingsSectionView(profile: profile, useInbuiltBrowser: $useInbuiltBrowser)
            #endif
            AppearanceSettingsSectionView(
                uiStyle: $uiStyle,
                contentSizeCategory: $contentSizeCategory
            )
            RefreshSettingsSectionView(
                autoRefreshEnabled: $autoRefreshEnabled,
                autoRefreshCooldown: $autoRefreshCooldown,
                backgroundRefreshEnabled: $backgroundRefreshEnabled
            )
            HistorySettingsSectionView(profile: profile, historyRentionDays: profile.wrappedHistoryRetention)
            ResetSettingsSectionView(
                activeProfile: $activeProfile,
                sceneProfileID: $sceneProfileID,
                appProfileID: $appProfileID,
                profile: profile
            )
            AboutSettingsSectionView()
        }
        .navigationTitle("Settings")
    }
}
