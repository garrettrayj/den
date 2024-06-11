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
    @Environment(RefreshManager.self) private var refreshManager
    
    @Binding var detailPanel: DetailPanel?
    @Binding var showingExporter: Bool
    @Binding var showingImporter: Bool
    @Binding var showingNewFeedSheet: Bool
    @Binding var showingNewPageSheet: Bool
    @Binding var showingNewTagSheet: Bool
    @Binding var showingSettings: Bool
    
    let feedCount: Int

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
                #if os(macOS)
                SettingsLink()
                #else
                SettingsButton(showingSettings: $showingSettings)
                #endif
            } label: {
                Label {
                    Text("Preferences", comment: "Menu label.")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .disabled(refreshManager.refreshing)
            .menuIndicator(.hidden)
            .help(Text("Show Menu", comment: "Menu help text."))
            .accessibilityIdentifier("SidebarMenu")
        }
        #if os(iOS)
        ToolbarItem(placement: .status) {
            SidebarStatus(feedCount: feedCount).layoutPriority(0)
        }
        ToolbarItem(placement: .bottomBar) {
            RefreshButton().disabled(feedCount == 0)
        }
        #endif
    }
}
