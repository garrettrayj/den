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
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var feedRefreshTimeout: Double
    @Binding var useSystemBrowser: Bool
    @Binding var userColorScheme: UserColorScheme

    var body: some View {
        TabView {
            GeneralSettingsTab(
                feedRefreshTimeout: $feedRefreshTimeout,
                userColorScheme: $userColorScheme
            )
            .tabItem {
                Label {
                    Text("General", comment: "App settings tab.")
                } icon: {
                    Image(systemName: "gearshape")
                }
            }
            .accessibilityIdentifier("GeneralTab")

            ProfilesSettingsTab()
            .tabItem {
                Label {
                    Text("Profiles", comment: "App settings tab.")
                } icon: {
                    Image(systemName: "person.crop.circle")
                }
            }
            .accessibilityIdentifier("ProfilesTab")
        }
        .frame(width: 560, height: 440)
    }
}
