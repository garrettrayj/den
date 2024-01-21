//
//  SidebarToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct SidebarToolbar: ToolbarContent {
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?
    @Binding var detailPanel: DetailPanel?
    @Binding var refreshing: Bool
    @Binding var refreshProgress: Progress
    @Binding var showingExporter: Bool
    @Binding var showingImporter: Bool
    @Binding var showingNewFeedSheet: Bool
    @Binding var showingNewPageSheet: Bool
    @Binding var showingNewTagSheet: Bool
    @Binding var showingSettings: Bool

    let profiles: [Profile]

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem(placement: .primaryAction) {
            Menu {
                NewFeedButton(showingNewFeedSheet: $showingNewFeedSheet)
                NewPageButton(showingNewPageSheet: $showingNewPageSheet)
                NewTagButton(showingNewTagSheet: $showingNewTagSheet)
                Divider()
                ImportButton(showingImporter: $showingImporter)
                ExportButton(showingExporter: $showingExporter)
                OrganizerButton(detailPanel: $detailPanel)
            } label: {
                Label {
                    Text("Menu", comment: "Button label.")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .menuIndicator(.hidden)
            .disabled(refreshing)
            .accessibilityIdentifier("SidebarMenu")
        }
        #else
        ToolbarItem(placement: .primaryAction) {
            Menu {
                NewFeedButton(showingNewFeedSheet: $showingNewFeedSheet)
                NewPageButton(showingNewPageSheet: $showingNewPageSheet)
                NewTagButton(showingNewTagSheet: $showingNewTagSheet)
                Divider()
                ImportButton(showingImporter: $showingImporter)
                ExportButton(showingExporter: $showingExporter)
                OrganizerButton(detailPanel: $detailPanel)
                SettingsButton(showingSettings: $showingSettings)
            } label: {
                Label {
                    Text("Preferences", comment: "Menu label.")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .disabled(refreshing)
            .accessibilityIdentifier("SidebarMenu")
        }
        ToolbarItem(placement: .bottomBar) {
            ProfilePickerMenu(
                profile: profile,
                profiles: profiles,
                currentProfileID: $currentProfileID
            )
            .disabled(refreshing)
        }
        ToolbarItem(placement: .status) {
            SidebarStatus(profile: profile, refreshing: $refreshing, refreshProgress: $refreshProgress)
        }
        ToolbarItem(placement: .bottomBar) {
            RefreshButton(
                profile: profile,
                refreshing: $refreshing,
                refreshProgress: $refreshProgress
            ).disabled(refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty)
        }
        #endif
    }
}
