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
    
    var body: some View {
        
        TabView {
            GeneralSettingsTab(
                userColorScheme: $userColorScheme
            )
            .tabItem {
                Label("General", systemImage: "gearshape")
            }
            
            ProfilesSettingsTab(activeProfile: $activeProfile, appProfileID: $appProfileID)
            .tabItem {
                Label("Profiles", systemImage: "person.crop.circle")
            }
            
            ResetSettingsTab(activeProfile: $activeProfile, appProfileID: $appProfileID, profile: profile)
            .tabItem {
                Label("Reset", systemImage: "trash")
            }
        }
        .frame(minWidth: 480, minHeight: 260)
    }
}
 
