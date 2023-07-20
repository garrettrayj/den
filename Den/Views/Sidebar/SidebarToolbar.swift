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

struct SidebarToolbar: CustomizableToolbarContent {
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?
    @Binding var detailPanel: DetailPanel?
    @Binding var feedRefreshTimeout: Int
    @Binding var isEditing: Bool
    @Binding var refreshing: Bool
    @Binding var showingExporter: Bool
    @Binding var showingImporter: Bool
    @Binding var showingProfileSettings: Bool
    
    let profiles: FetchedResults<Profile>
    let refreshProgress: Progress
    
    private var activePage: Page? {
        if case .page(let page) = detailPanel {
            return page
        }
        return nil
    }

    var body: some CustomizableToolbarContent {
        #if os(macOS)
        ToolbarItem(id: "Refresh") {
            RefreshButton(
                profile: profile,
                feedRefreshTimeout: $feedRefreshTimeout,
                refreshing: $refreshing,
                refreshProgress: refreshProgress
            )
            .disabled(refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty)
        }
        
        ToolbarItem(id: "SidebarMenu", placement: .primaryAction) {
            Menu {
                NewFeedButton(profile: profile, page: activePage)
                NewPageButton(profile: profile)
                
                Divider()
                
                ImportButton(showingImporter: $showingImporter)
                ExportButton(showingExporter: $showingExporter)
                DiagnosticsButton(detailPanel: $detailPanel)
                ProfileSettingsButton(showingProfileSettings: $showingProfileSettings)
            } label: {
                Label {
                    Text("Menu", comment: "Button label.")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .accessibilityIdentifier("SidebarMenu")
        }
        #else
        if isEditing {
            ToolbarItem(id: "SidebarDone", placement: .primaryAction) {
                Button {
                    withAnimation {
                        isEditing = false
                    }
                } label: {
                    Text("Done", comment: "Button label.")
                }
            }
        } else {
            ToolbarItem(id: "SidebarMenu", placement: .primaryAction) {
                Menu {
                    NewFeedButton(profile: profile, page: activePage)
                    NewPageButton(profile: profile)
                    Divider()
                    Button {
                        withAnimation {
                            isEditing = true
                        }
                    } label: {
                        Label {
                            Text("Edit Pages", comment: "Button label.")
                        } icon: {
                            Image(systemName: "pencil")
                        }
                    }
                    .accessibilityIdentifier("EditPages")
                    ImportButton(showingImporter: $showingImporter)
                    ExportButton(showingExporter: $showingExporter)
                    DiagnosticsButton(detailPanel: $detailPanel)
                    ProfileSettingsButton(showingProfileSettings: $showingProfileSettings)
                } label: {
                    Label {
                        Text("Preferences", comment: "Menu label.")
                    } icon: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                .accessibilityIdentifier("SidebarMenu")
            }
        }
        
        ToolbarItem(id: "ProfileMenu", placement: .bottomBar) {
            Menu {
                NewProfileButton(currentProfileID: $currentProfileID)
                ProfilePicker(currentProfileID: $currentProfileID, profiles: profiles)
            } label: {
                Label {
                    profile.nameText
                } icon: {
                    Image(systemName: "person.crop.circle")
                }
            }
            .accessibilityIdentifier("ProfileMenu")
        }
        
        ToolbarItem(id: "SidebarStatus", placement: .status) {
            BottomBarSidebarStatus(profile: profile, progress: refreshProgress, refreshing: $refreshing)
        }
        
        ToolbarItem(id: "SidebarBottomRefresh", placement: .bottomBar) {
            RefreshButton(
                profile: profile,
                feedRefreshTimeout: $feedRefreshTimeout,
                refreshing: $refreshing,
                refreshProgress: refreshProgress
            ).disabled(refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty)
        }
        #endif
    }
}
