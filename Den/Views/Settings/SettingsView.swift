//
//  SettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Binding var activeProfileID: String?
    @Binding var lastProfileID: String?
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
            BrowserSectionView(profile: profile, useInbuiltBrowser: $useInbuiltBrowser)
            HistorySectionView(profile: profile, historyRentionDays: profile.wrappedHistoryRetention)
            AutoRefreshSectionView(
                autoRefreshEnabled: $autoRefreshEnabled,
                autoRefreshCooldown: $autoRefreshCooldown,
                backgroundRefreshEnabled: $backgroundRefreshEnabled
            )
            AppearanceSectionView(uiStyle: $uiStyle)
            ResetSectionView(
                activeProfileID: $activeProfileID,
                lastProfileID: $lastProfileID,
                profile: profile
            )
            AboutSectionView()
        }
        .navigationTitle("Settings")
        .navigationDestination(for: SettingsPanel.self) { settingsPanel in
            switch settingsPanel {
            case .profileSettings(let profile):
                if profile.managedObjectContext != nil {
                    ProfileView(
                        activeProfileID: $activeProfileID,
                        lastProfileID: $lastProfileID,
                        profile: profile,
                        nameInput: profile.wrappedName
                    )
                } else {
                    StatusBoxView(message: Text("Profile Deleted"), symbol: "slash.circle")
                }
            case .importFeeds:
                ImportView(profile: profile)
            case .exportFeeds:
                ExportView(profile: profile)
            case .security:
                SecurityView(profile: profile)
            }
        }
    }
}
