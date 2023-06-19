//
//  SidebarToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SidebarToolbar: ToolbarContent {
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @EnvironmentObject private var refreshManager: RefreshManager
    
    @ObservedObject var profile: Profile

    @Binding var showingSettings: Bool
    @Binding var contentSelection: DetailPanel?
    
    private var activePage: Page? {
        if case .page(let page) = contentSelection {
            return page
        }
        return nil
    }

    var body: some ToolbarContent {
        #if os(iOS)
        ToolbarItem {
            EditButton()
                .buttonStyle(ToolbarButtonStyle())
                .disabled(refreshManager.refreshing || profile.pagesArray.isEmpty)
                .accessibilityIdentifier("edit-page-list-button")
        }
        ToolbarItem(placement: .bottomBar) {
            SettingsButton(showingSettings: $showingSettings).disabled(refreshManager.refreshing)
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            SidebarStatus(
                profile: profile,
                refreshing: $refreshManager.refreshing
            )
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            RefreshButton(profile: profile)
                .buttonStyle(PlainToolbarButtonStyle())
                .disabled(
                    refreshManager.refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty
                )
        }
        #else
        ToolbarItem {
            if refreshManager.refreshing {
                RefreshProgress(totalUnitCount: profile.feedsArray.count)
            } else {
                RefreshButton(profile: profile)
                    .buttonStyle(ToolbarButtonStyle())
                    .disabled(
                        refreshManager.refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty
                    )
            }
        }
        ToolbarItem {
            AddFeedButton(page: activePage)
                .buttonStyle(ToolbarButtonStyle())
                .disabled(
                    refreshManager.refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty
                )
        }
        #endif
    }
}
