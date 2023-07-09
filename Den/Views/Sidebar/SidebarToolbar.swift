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

    @Binding var activeProfile: Profile?
    @Binding var isEditing: Bool
    @Binding var showingSettings: Bool
    @Binding var detailPanel: DetailPanel?
    @Binding var feedRefreshTimeout: Double
    @Binding var showingImporter: Bool
    @Binding var showingExporter: Bool

    private var activePage: Page? {
        if case .page(let page) = detailPanel {
            return page
        }
        return nil
    }

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            NewFeedButton(page: activePage).disabled(refreshManager.refreshing || profile.pagesArray.isEmpty)
        }
        ToolbarItem {
            if refreshManager.refreshing {
                RefreshProgress(totalUnitCount: profile.feedsArray.count)
            } else {
                RefreshButton(activeProfile: .constant(profile), feedRefreshTimeout: $feedRefreshTimeout)
                    .disabled(
                        refreshManager.refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty
                    )
            }
        }
        #else
        if isEditing {
            ToolbarItem {
                Button {
                    withAnimation {
                        isEditing = false
                    }
                } label: {
                    Text("Done", comment: "Button label.")
                }
            }
        } else {
            ToolbarItem {
                Menu {
                    ProfilePicker(activeProfile: $activeProfile)
                    Button {
                        withAnimation {
                            isEditing = true
                        }
                    } label: {
                        Text("Edit Pages", comment: "Button label.")
                    }
                    .disabled(refreshManager.refreshing || profile.pagesArray.isEmpty)
                    .accessibilityIdentifier("edit-page-list-button")
                    .buttonStyle(.borderless)
                    
                    ImportButton(showingImporter: $showingImporter)
                        .buttonStyle(.borderless)
                    ExportButton(showingExporter: $showingExporter)
                        .buttonStyle(.borderless)
                    
                    SettingsButton(showingSettings: $showingSettings).disabled(refreshManager.refreshing)
                } label: {
                    Label {
                        Text("Menu", comment: "Button label.")
                    } icon: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        
        ToolbarItemGroup(placement: .bottomBar) {
            NewFeedButton(page: activePage)
                .disabled(refreshManager.refreshing || profile.pagesArray.isEmpty)
            Spacer()
            SidebarStatus(
                profile: profile,
                refreshing: $refreshManager.refreshing
            )
            Spacer()
            RefreshButton(activeProfile: .constant(profile), feedRefreshTimeout: $feedRefreshTimeout)
                .disabled(
                    refreshManager.refreshing ||
                    !networkMonitor.isConnected ||
                    profile.pagesArray.isEmpty
                )
        }
        #endif
    }
}
