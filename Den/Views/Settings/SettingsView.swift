//
//  SettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Binding var activeProfile: Profile?
    @Binding var uiStyle: UIUserInterfaceStyle
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    
    @ObservedObject var profile: Profile

    var body: some View {
        Form {
            ProfilesSectionView(activeProfile: $activeProfile)
            FeedsSectionView()
            HistorySectionView(profile: profile, historyRentionDays: profile.wrappedHistoryRetention)
            AutoRefreshSectionView(
                autoRefreshEnabled: $autoRefreshEnabled,
                autoRefreshCooldown: $autoRefreshCooldown,
                backgroundRefreshEnabled: $backgroundRefreshEnabled
            )
            AppearanceSectionView(uiStyle: $uiStyle)
            ResetSectionView(activeProfile: $activeProfile, profile: profile)
            AboutSectionView()
        }
        .navigationTitle("Settings")
        .navigationDestination(for: SettingsPanel.self) { settingsPanel in
            switch settingsPanel {
            case .profile(let profile):
                if profile.managedObjectContext == nil {
                    StatusBoxView(message: Text("Profile Deleted"), symbol: "slash.circle")
                } else {
                    ProfileView(
                        activeProfile: $activeProfile,
                        profile: profile,
                        nameInput: profile.wrappedName
                    )
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
