//
//  SettingsTabs.swift
//  Den
//
//  Created by Garrett Johnson on 6/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI


struct SettingsTabs: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var useSystemBrowser: Bool
    @Binding var userColorScheme: UserColorScheme
    @Binding var detailPanel: DetailPanel?
    
    var body: some View {
        TabView {
            GeneralSettingsTab(
                activeProfile: $activeProfile,
                appProfileID: $appProfileID,
                userColorScheme: $userColorScheme
            )
            .tabItem {
                Label("General", systemImage: "gearshape")
            }
            
            ProfilesSettingsTab(activeProfile: $activeProfile, appProfileID: $appProfileID, detailPanel: $detailPanel)
            .tabItem {
                Label("Profiles", systemImage: "person.crop.circle")
            }
        }
        .frame(minWidth: 480, minHeight: 320)
    }
}
 
