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
    
    let feedCount: Int

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                NewFeedButton()
                NewPageButton()
                Divider()
                ImportButton()
                ExportButton()
                Divider()
                OrganizerButton(detailPanel: $detailPanel)
                #if os(macOS)
                SettingsLink()
                #else
                SettingsButton()
                #endif
            } label: {
                Label {
                    Text("Menu", comment: "Menu label.")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .disabled(refreshManager.refreshing)
            .menuIndicator(.hidden)
            .help(Text("Show menu", comment: "Menu help text."))
            .accessibilityIdentifier("SidebarMenu")
        }
        #if os(iOS)
        ToolbarItem(placement: .status) {
            SidebarStatus(feedCount: feedCount)
        }
        ToolbarItem(placement: .bottomBar) {
            RefreshButton().disabled(feedCount == 0)
        }
        #endif
    }
}
