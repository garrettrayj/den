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

    @ObservedObject var viewModel: SidebarViewModel

    /**
     Switch refreshable() on and off depending on environment and page count.
     
         SwiftUI.SwiftUI_UIRefreshControl is not supported when running Catalyst apps in the Mac idiom.
         See UIBehavioralStyle for possible alternatives.
         Consider using a Refresh menu item bound to ⌘-R
     */
    var body: some View {
        Group {
            if viewModel.profile.pagesArray.isEmpty {
                StartListView(viewModel: viewModel)
            } else {
                NavigationListView(viewModel: viewModel)
                #if !targetEnvironment(macCatalyst)
                .refreshable {
                    refreshManager.refresh(profile: viewModel.profile)
                }
                #endif
            }
        }
        .background(
            NavigationLink(isActive: $viewModel.showingSettings) {
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
        .navigationTitle(viewModel.profile.displayName)
    }
}
