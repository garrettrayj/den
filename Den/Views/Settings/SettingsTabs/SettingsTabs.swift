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
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var feedRefreshTimeout: Double
    @Binding var useSystemBrowser: Bool
    @Binding var userColorScheme: UserColorScheme

    var body: some View {
        TabView {
            GeneralSettingsTab(
                activeProfile: $activeProfile,
                feedRefreshTimeout: $feedRefreshTimeout,
                userColorScheme: $userColorScheme
            )
            .tabItem {
                Label("General", systemImage: "gearshape")
            }

            ProfilesSettingsTab(activeProfile: $activeProfile)
            .tabItem {
                Label("Profiles", systemImage: "person.crop.circle")
            }
        }
        .frame(minWidth: 480, minHeight: 400)
    }
}
