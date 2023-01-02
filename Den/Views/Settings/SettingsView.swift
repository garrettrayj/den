//
//  SettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson
//

import SwiftUI

struct SettingsView: View {
    @Binding var activeProfileID: String?
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
            ProfilesSectionView(activeProfileID: $activeProfileID)
            FeedsSectionView()
            #if !targetEnvironment(macCatalyst)
            BrowserSectionView(profile: profile, useInbuiltBrowser: $useInbuiltBrowser)
            #endif
            HistorySectionView(profile: profile, historyRentionDays: profile.wrappedHistoryRetention)
            AutoRefreshSectionView(
                autoRefreshEnabled: $autoRefreshEnabled,
                autoRefreshCooldown: $autoRefreshCooldown,
                backgroundRefreshEnabled: $backgroundRefreshEnabled
            )
            AppearanceSectionView(uiStyle: $uiStyle)
            ResetSectionView(
                activeProfileID: $activeProfileID,
                appProfileID: $appProfileID,
                profile: profile
            )
            AboutSectionView()
        }
        .navigationTitle("Settings")
    }
}
