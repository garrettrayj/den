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
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var cacheManager: CacheManager
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var themeManager: ThemeManager

    @ObservedObject var viewModel: ProfileViewModel

    @State var showingSettings: Bool = false

    /**
     Switch refreshable() on and off depending on environment and page count.
     
         SwiftUI.SwiftUI_UIRefreshControl is not supported when running Catalyst apps in the Mac idiom.
         See UIBehavioralStyle for possible alternatives.
         Consider using a Refresh menu item bound to ⌘-R
     */
    var body: some View {
        Group {
            if viewModel.profile.pagesArray.isEmpty {
                StartListView(viewModel: viewModel, showingSettings: $showingSettings)
            } else {
                NavigationListView(profileViewModel: viewModel, showingSettings: $showingSettings)
                #if !targetEnvironment(macCatalyst)
                .refreshable {
                    refreshManager.refresh(profile: viewModel.profile)
                }
                #endif
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
        .navigationTitle(viewModel.profile.displayName)
    }
}
