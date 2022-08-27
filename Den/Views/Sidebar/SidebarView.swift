//
//  SidebarView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 Master navigation list with links to page views.
*/
struct SidebarView: View {
    @EnvironmentObject private var profileManager: ProfileManager

    @State private var showingSettings: Bool = false

    /**
     Switch refreshable() on and off depending on environment and page count.
     
         SwiftUI.SwiftUI_UIRefreshControl is not supported when running Catalyst apps in the Mac idiom.
         See UIBehavioralStyle for possible alternatives.
         Consider using a Refresh menu item bound to ⌘-R
     */
    var body: some View {
        Group {
            if profileManager.activeProfile?.id == nil {
                ProfileNotAvailableView(showingSettings: $showingSettings)
            } else if profileManager.activeProfile!.pagesArray.isEmpty {
                StartListView(
                    profile: profileManager.activeProfile!,
                    showingSettings: $showingSettings
                )
            } else {
                NavigationListView(
                    profile: profileManager.activeProfile!,
                    showingSettings: $showingSettings
                )
            }
        }
        .background(
            NavigationLink(isActive: $showingSettings) {
                SettingsView()
            } label: {
                Label("Settings", systemImage: "gear")
            }.hidden()
        )
        .navigationTitle(profileManager.activeProfile?.displayName ?? "")
    }
}
