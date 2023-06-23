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
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var detailPanel: DetailPanel?
    @Binding var searchQuery: String
    @Binding var showingSettings: Bool

    @State private var searchInput = ""

    var body: some View {
        List(selection: $detailPanel) {
            if profile.pagesArray.isEmpty {
                Start(profile: profile)
            } else {
                AllSection(profile: profile)
                PagesSection(profile: profile)
            }
        }
        #if os(macOS)
        .safeAreaInset(edge: .bottom, alignment: .leading) {
            if !profile.pagesArray.isEmpty {
                NewPageButton(activeProfile: .constant(profile))
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
            }
        }
        #endif
        .listStyle(.sidebar)
        .searchable(
            text: $searchInput,
            placement: .sidebar,
            prompt: Text("Search", comment: "Search field prompt.")
        )
        .onSubmit(of: .search) {
            searchQuery = searchInput
            detailPanel = .search
        }
        #if os(iOS)
        .scrollContentBackground(.hidden)
        #endif
        .disabled(refreshManager.refreshing)
        .navigationTitle(profile.nameText)
        .toolbar {
            SidebarToolbar(
                profile: profile,
                showingSettings: $showingSettings,
                detailPanel: $detailPanel
            )
        }
    }
}
