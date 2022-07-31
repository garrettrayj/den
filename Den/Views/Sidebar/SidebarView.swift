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
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var cacheManager: CacheManager
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var themeManager: ThemeManager

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
            if profile.id == nil {
                MissingProfileView(showingSettings: $showingSettings)
            } else if profile.pagesArray.isEmpty {
                StartListView(
                    profile: profile,
                    showingSettings: $showingSettings
                )
            } else {
                NavigationListView(
                    profile: profile,
                    showingSettings: $showingSettings
                )
            }
        }
        .background(
            NavigationLink(isActive: $showingSettings) {
                SettingsView(viewModel: SettingsViewModel(
                    viewContext: viewContext,
                    crashManager: crashManager,
                    profileManager: profileManager,
                    refreshManager: refreshManager,
                    cacheManager: cacheManager,
                    themeManager: themeManager
                ))
            } label: {
                Label("Settings", systemImage: "gear")
            }.hidden()
        )
        .navigationTitle(profile.displayName)
    }
}
