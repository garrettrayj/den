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
    @Binding var activeProfile: Profile?
    @ObservedObject var profile: Profile
    @State private var showingSettings: Bool = false

    /**
     Switch refreshable() on and off depending on environment and page count.
     
         SwiftUI.SwiftUI_UIRefreshControl is not supported when running Catalyst apps in the Mac idiom.
         See UIBehavioralStyle for possible alternatives.
         Consider using a Refresh menu item bound to ⌘-R
     */
    var body: some View {
        Group {
            if profile.pagesArray.isEmpty {
                StartListView(
                    profile: activeProfile!,
                    showingSettings: $showingSettings
                )
            } else {
                NavigationListView(
                    profile: activeProfile!,
                    showingSettings: $showingSettings
                )
            }
        }
        .background(
            NavigationLink(isActive: $showingSettings) {
                SettingsView(activeProfile: $activeProfile)
            } label: {
                Label("Settings", systemImage: "gear")
            }.hidden()
        )
        .navigationTitle(profile.displayName)
    }
}
