//
//  Sidebar.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct Sidebar: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var contentSelection: ContentPanel?
    @Binding var searchQuery: String

    @State private var searchInput: String = ""

    var body: some View {
        List(selection: $contentSelection) {
            if profile.pagesArray.isEmpty {
                Start(profile: profile)
            } else {
                InboxNav(profile: profile)
                TrendingNav(profile: profile)
                PagesSection(profile: profile)
            }
        }
        .listStyle(.sidebar)
        .searchable(
            text: $searchInput,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .onSubmit(of: .search) {
            searchQuery = searchInput
            contentSelection = .search
        }
        .tint(profile.tintColor)
        #if targetEnvironment(macCatalyst)
        .background(.thickMaterial)
        .background(.background)
        #else
        .background(GroupedBackground())
        #endif
        .disabled(refreshManager.refreshing)
        .navigationTitle(profile.displayName)
        .toolbar {
            ToolbarItem {
                EditButton()
                    .buttonStyle(ToolbarButtonStyle())
                    .disabled(refreshManager.refreshing || profile.pagesArray.isEmpty)
                    .accessibilityIdentifier("edit-page-list-button")
            }
            ToolbarItem(placement: .bottomBar) {
                SettingsButton(listSelection: $contentSelection).disabled(refreshManager.refreshing)
            }
            ToolbarItem(placement: .bottomBar) { Spacer() }
            ToolbarItem(placement: .bottomBar) {
                SidebarStatus(
                    profile: profile,
                    refreshing: $refreshManager.refreshing,
                    progress: Progress(totalUnitCount: Int64(profile.feedsArray.count))
                )
            }
            ToolbarItem(placement: .bottomBar) { Spacer() }
            ToolbarItem(placement: .bottomBar) {
                RefreshButton(profile: profile)
                    .disabled(
                        refreshManager.refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty
                    )
            }
        }
    }
}
