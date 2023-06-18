//
//  SettingsSheetForm.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsSheetForm: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var useSystemBrowser: Bool
    @Binding var userColorScheme: UserColorScheme

    var body: some View {
        Form {
            SettingsSheetProfilesSection(activeProfile: $activeProfile, appProfileID: $appProfileID)
            
            Section {
                ImportButton(activeProfile: $activeProfile)
                ExportButton(activeProfile: $activeProfile)
            } header: {
                Text("OPML")
            }
            
            SettingsSheetAppearanceSection(userColorScheme: $userColorScheme)
            #if os(iOS)
            SettingsSheetBrowserSection(useSystemBrowser: $useSystemBrowser)
            #endif
            SettingsSheetRefreshSection(
                backgroundRefreshEnabled: $backgroundRefreshEnabled
            )
            SettingsSheetResetSection(
                activeProfile: $activeProfile,
                appProfileID: $appProfileID
            )
            SettingsSheetAboutSection()
        }
        .navigationTitle(Text("Settings", comment: "Navigation title."))
    }
}
