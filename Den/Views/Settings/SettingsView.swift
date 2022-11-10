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
                ProfileView(
                    activeProfile: $activeProfile,
                    profile: profile,
                    nameInput: profile.wrappedName
                ).id(profile.id)
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
