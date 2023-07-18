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

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?
    @Binding var detailPanel: DetailPanel?
    @Binding var feedRefreshTimeout: Double
    @Binding var isEditing: Bool
    @Binding var refreshing: Bool
    @Binding var showingExporter: Bool
    @Binding var showingImporter: Bool
    @Binding var showingSettings: Bool
    
    let profiles: FetchedResults<Profile>
    let refreshProgress: Progress
    
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
                ProfilePicker(currentProfileID: $currentProfileID, profiles: profiles)
                
                Divider()
                
                NewFeedButton(profile: profile, page: activePage)
                    .disabled(refreshing || profile.pagesArray.isEmpty)
                
                NewPageButton(profile: profile)
                
                Divider()
                
                ImportButton(showingImporter: $showingImporter)
                    .labelStyle(.titleOnly)
                    .buttonStyle(.borderless)
                
                ExportButton(showingExporter: $showingExporter)
                    .labelStyle(.titleOnly)
                    .buttonStyle(.borderless)
                    .disabled(profile.pagesArray.isEmpty)
                
                DiagnosticsButton(detailPanel: $detailPanel)
            } label: {
                Label {
                    Text("Menu", comment: "Button label.")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .disabled(refreshing)
            .accessibilityIdentifier("AppMenu")
        }
    
        ToolbarItem {
            if refreshing {
                RefreshProgress(profile: profile, progress: refreshProgress)
            } else {
                RefreshButton(profile: profile, feedRefreshTimeout: $feedRefreshTimeout)
                    .disabled(
                        refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty
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
                    ProfilePicker(currentProfileID: $currentProfileID, profiles: profiles)
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
                    
                    DiagnosticsButton(detailPanel: $detailPanel)
                    
                    SettingsButton(showingSettings: $showingSettings).disabled(refreshing)
                } label: {
                    Label {
                        Text("Menu", comment: "Button label.")
                    } icon: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                .disabled(refreshing)
                .accessibilityIdentifier("AppMenu")
            }
        }
        
        ToolbarItemGroup(placement: .bottomBar) {
            NewFeedButton(profile: profile, page: activePage)
                .disabled(refreshing || profile.pagesArray.isEmpty)
            Spacer()
            BottomBarSidebarStatus(profile: profile, progress: refreshProgress, refreshing: $refreshing)
            Spacer()
            RefreshButton(profile: profile, feedRefreshTimeout: $feedRefreshTimeout)
                .disabled(refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty)
        }
        #endif
    }
}
