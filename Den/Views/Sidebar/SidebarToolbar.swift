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

    @Binding var currentProfile: Profile?
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
            Menu {
                ProfilePicker(currentProfile: $currentProfile)
                
                Divider()
                
                NewFeedButton(page: activePage)
                    .disabled(refreshManager.refreshing || profile.pagesArray.isEmpty)
                
                NewPageButton(currentProfile: $currentProfile)
                
                Divider()
                
                ImportButton(showingImporter: $showingImporter)
                    .labelStyle(.titleOnly)
                    .buttonStyle(.borderless)
                
                ExportButton(showingExporter: $showingExporter)
                    .labelStyle(.titleOnly)
                    .buttonStyle(.borderless)
                    .disabled(profile.pagesArray.isEmpty)
                
                DiagnosticsButton()
            } label: {
                Label {
                    Text("Menu", comment: "Button label.")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .disabled(refreshManager.refreshing)
            .accessibilityIdentifier("AppMenu")
        }
    
        ToolbarItem {
            if refreshManager.refreshing {
                RefreshProgress(totalUnitCount: profile.feedsArray.count)
            } else {
                RefreshButton(currentProfile: .constant(profile), feedRefreshTimeout: $feedRefreshTimeout)
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
                    ProfilePicker(currentProfile: $currentProfile)
                    Button {
                        withAnimation {
                            isEditing = true
                        }
                    } label: {
                        Text("Edit Pages", comment: "Button label.")
                    }
                    .disabled(profile.pagesArray.isEmpty)
                    .accessibilityIdentifier("EditPages")
                    .buttonStyle(.borderless)
                    
                    ImportButton(showingImporter: $showingImporter)
                        .labelStyle(.titleOnly)
                        .buttonStyle(.borderless)
                    
                    ExportButton(showingExporter: $showingExporter)
                        .labelStyle(.titleOnly)
                        .buttonStyle(.borderless)
                        .disabled(profile.pagesArray.isEmpty)
                    
                    DiagnosticsButton()
                    
                    SettingsButton(showingSettings: $showingSettings).disabled(refreshManager.refreshing)
                } label: {
                    Label {
                        Text("Menu", comment: "Button label.")
                    } icon: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                .disabled(refreshManager.refreshing)
                .accessibilityIdentifier("AppMenu")
            }
        }
        
        ToolbarItemGroup(placement: .bottomBar) {
            NewFeedButton(page: activePage)
                .disabled(refreshManager.refreshing || profile.pagesArray.isEmpty)
            Spacer()
            BottomBarSidebarStatus(profile: profile)
            Spacer()
            RefreshButton(currentProfile: .constant(profile), feedRefreshTimeout: $feedRefreshTimeout)
                .disabled(
                    refreshManager.refreshing ||
                    !networkMonitor.isConnected ||
                    profile.pagesArray.isEmpty
                )
        }
        #endif
    }
}
