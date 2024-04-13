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

    @Binding var detailPanel: DetailPanel?
    @Binding var refreshing: Bool
    @Binding var refreshProgress: Progress
    @Binding var showingExporter: Bool
    @Binding var showingImporter: Bool
    @Binding var showingNewFeedSheet: Bool
    @Binding var showingNewPageSheet: Bool
    @Binding var showingNewTagSheet: Bool
    @Binding var showingSettings: Bool
    
    let pages: FetchedResults<Page>

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                NewFeedButton(showingNewFeedSheet: $showingNewFeedSheet)
                NewPageButton(showingNewPageSheet: $showingNewPageSheet)
                NewTagButton(showingNewTagSheet: $showingNewTagSheet)
                Divider()
                ImportButton(showingImporter: $showingImporter)
                ExportButton(showingExporter: $showingExporter)
                Divider()
                OrganizerButton(detailPanel: $detailPanel)
                #if !os(macOS)
                SettingsButton(showingSettings: $showingSettings)
                #endif
            } label: {
                Label {
                    Text("Preferences", comment: "Menu label.")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .disabled(refreshing)
            .menuIndicator(.hidden)
            .accessibilityIdentifier("SidebarMenu")
        }
        #if os(iOS)
        ToolbarItem(placement: .status) {
            SidebarStatus(
                refreshing: $refreshing,
                refreshProgress: $refreshProgress, 
                pages: pages
            )
            .layoutPriority(0)
        }
        ToolbarItem(placement: .bottomBar) {
            RefreshButton()
                .disabled(refreshing || !networkMonitor.isConnected || pages.isEmpty)
        }
        #endif
    }
}
