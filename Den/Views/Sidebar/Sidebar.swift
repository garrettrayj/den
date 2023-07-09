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
    
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var currentProfile: Profile?
    @Binding var detailPanel: DetailPanel?
    @Binding var showingSettings: Bool
    @Binding var feedRefreshTimeout: Double
    @Binding var showingImporter: Bool
    @Binding var showingExporter: Bool

    @State private var searchInput = ""
    @State private var isEditing = false

    var body: some View {
        List(selection: $detailPanel) {
            if profile.pagesArray.isEmpty {
                Start(profile: profile, showingImporter: $showingImporter)
            } else {
                AllSection(profile: profile)
                PagesSection(profile: profile)
            }
        }
        #if os(macOS)
        .safeAreaInset(edge: .bottom, alignment: .leading) {
            if !profile.pagesArray.isEmpty {
                NewPageButton(currentProfile: .constant(profile))
                    .buttonStyle(.plain)
                    .font(.callout)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
            }
        }
        #else
        .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
        #endif
        .listStyle(.sidebar)
        .searchable(
            text: $searchInput,
            placement: .sidebar,
            prompt: Text("Search", comment: "Search field prompt.")
        )
        .onSubmit(of: .search) {
            detailPanel = .search(searchInput)
        }
        .task {
            if case .search(let query) = detailPanel {
                searchInput = query
            }
        }
        .disabled(refreshManager.refreshing)
        .navigationTitle(profile.nameText)
        .toolbar {
            SidebarToolbar(
                profile: profile,
                currentProfile: $currentProfile,
                isEditing: $isEditing,
                showingSettings: $showingSettings,
                detailPanel: $detailPanel,
                feedRefreshTimeout: $feedRefreshTimeout,
                showingImporter: $showingImporter,
                showingExporter: $showingExporter
            )
        }
    }
}
