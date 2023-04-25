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
        .background(.ultraThinMaterial.opacity(colorScheme == .dark ? 0 : 1))
        #if targetEnvironment(macCatalyst)
        .navigationSplitViewColumnWidth(224)
        #else
        .navigationSplitViewColumnWidth(264 * dynamicTypeSize.layoutScalingFactor)
        .refreshable {
            if networkMonitor.isConnected {
                await refreshManager.refresh(profile: profile)
            }
        }
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
            ToolbarItemGroup(placement: .bottomBar) {
                HStack {
                    SettingsButton(listSelection: $contentSelection).disabled(refreshManager.refreshing)
                    Spacer()
                    SidebarStatus(
                        profile: profile,
                        refreshing: $refreshManager.refreshing,
                        progress: Progress(totalUnitCount: Int64(profile.feedsArray.count))
                    )
                    Spacer()
                    RefreshButton(profile: profile)
                        .disabled(
                            refreshManager.refreshing || profile.pagesArray.isEmpty || !networkMonitor.isConnected
                        )
                }
            }
        }
    }
}
