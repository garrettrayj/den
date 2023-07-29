//
//  Sidebar.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct Sidebar: View {
    #if os(iOS)
    @Environment(\.editMode) private var editMode
    #endif

    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?
    @Binding var detailPanel: DetailPanel?
    @Binding var feedRefreshTimeout: Int
    @Binding var refreshing: Bool
    @Binding var showingExporter: Bool
    @Binding var showingImporter: Bool
    @Binding var showingProfileSettings: Bool

    @State private var searchInput = ""
    @State private var isEditing = false

    let profiles: FetchedResults<Profile>
    let refreshProgress: Progress

    var body: some View {
        List(selection: $detailPanel) {
            if profile.pagesArray.isEmpty {
                Start(profile: profile, detailPanel: $detailPanel, showingImporter: $showingImporter)
            } else {
                #if os(macOS)
                Section {
                    InboxNavLink(profile: profile)
                    TrendingNavLink(profile: profile)
                } header: {
                    Text("All Feeds", comment: "Sidebar section header.")
                }
                #else
                InboxNavLink(profile: profile)
                TrendingNavLink(profile: profile)
                #endif

                PagesSection(profile: profile)
            }
        }
        .listStyle(.sidebar)
        .searchable(
            text: $searchInput,
            placement: .sidebar,
            prompt: Text("Search", comment: "Search field prompt.")
        )
        .onSubmit(of: .search) {
            detailPanel = .search(searchInput)
        }
        #if os(iOS)
        .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
        .refreshable {
            guard !refreshing && networkMonitor.isConnected else { return }
            if let profile = profiles.firstMatchingID(currentProfileID) {
                await refreshManager.refresh(profile: profile, timeout: feedRefreshTimeout)
            }
        }
        #endif
        .disabled(refreshing)
        .navigationTitle(profile.nameText)
        .toolbar(id: "Sidebar") {
            SidebarToolbar(
                profile: profile,
                currentProfileID: $currentProfileID,
                detailPanel: $detailPanel,
                feedRefreshTimeout: $feedRefreshTimeout,
                isEditing: $isEditing,
                refreshing: $refreshing,
                showingExporter: $showingExporter,
                showingImporter: $showingImporter,
                showingProfileSettings: $showingProfileSettings,
                profiles: profiles,
                refreshProgress: refreshProgress
            )
        }
        #if os(macOS)
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading) {
                Menu {
                    ProfilePicker(currentProfileID: $currentProfileID, profiles: profiles)
                        .pickerStyle(.inline)
                    NewProfileButton(currentProfileID: $currentProfileID)
                } label: {
                    Label {
                        profile.nameText
                    } icon: {
                        Image(systemName: "person.crop.circle")
                    }
                }
                .menuStyle(.borderlessButton)
                .labelStyle(.titleAndIcon)
                .accessibilityIdentifier("ProfileMenu")
                .disabled(refreshing)
                
                SidebarStatus(profile: profile, progress: refreshProgress, refreshing: $refreshing)
            }
            .padding()
        }
        #endif
    }
}
