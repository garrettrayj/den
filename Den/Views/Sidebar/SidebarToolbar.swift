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
    @Binding var isEditing: Bool
    @Binding var refreshing: Bool
    @Binding var showingExporter: Bool
    @Binding var showingImporter: Bool
    @Binding var showingNewFeedSheet: Bool
    @Binding var showingNewPageSheet: Bool
    @Binding var showingNewProfileSheet: Bool
    @Binding var showingNewTagSheet: Bool
    @Binding var showingProfileOptions: Bool

    let profiles: [Profile]
    let refreshProgress: Progress

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem(placement: .primaryAction) {
            RefreshButton(
                profile: profile,
                refreshing: $refreshing,
                refreshProgress: refreshProgress
            )
            .disabled(refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty)
        }
        ToolbarItem(placement: .primaryAction) {
            Menu {
                NewFeedButton(showingNewFeedSheet: $showingNewFeedSheet)
                NewPageButton(showingNewPageSheet: $showingNewPageSheet)
                NewTagButton(showingNewTagSheet: $showingNewTagSheet)
                Divider()
                ImportButton(showingImporter: $showingImporter)
                ExportButton(showingExporter: $showingExporter)
                ProfileOptionsButton(showingProfileOptions: $showingProfileOptions)
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
        if isEditing {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation {
                        isEditing = false
                    }
                } label: {
                    Text("Done", comment: "Button label.")
                }
            }
        } else {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    NewFeedButton(showingNewFeedSheet: $showingNewFeedSheet)
                    NewPageButton(showingNewPageSheet: $showingNewPageSheet)
                    NewTagButton(showingNewTagSheet: $showingNewTagSheet)
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
                    ProfileOptionsButton(showingProfileOptions: $showingProfileOptions)
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
        }
        ToolbarItem(placement: .bottomBar) {
            Menu {
                NewProfileButton(showingNewProfileSheet: $showingNewProfileSheet)
                ProfilePicker(currentProfileID: $currentProfileID, profiles: profiles)
            } label: {
                Label {
                    profile.nameText
                } icon: {
                    Image(systemName: "person.crop.circle")
                }
            }
            .menuOrder(.fixed)
            .disabled(refreshing)
            .accessibilityIdentifier("ProfileMenu")
        }
        ToolbarItem(placement: .status) {
            SidebarStatus(profile: profile, progress: refreshProgress, refreshing: $refreshing)
        }
        ToolbarItem(placement: .bottomBar) {
            RefreshButton(
                profile: profile,
                refreshing: $refreshing,
                refreshProgress: refreshProgress
            ).disabled(refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty)
        }
        #endif
    }
}
