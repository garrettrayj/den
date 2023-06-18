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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var contentSelection: DetailPanel?
    @Binding var searchQuery: String
    @Binding var showingSettings: Bool

    @State private var searchInput = ""

    var body: some View {
        List(selection: $contentSelection) {
            if profile.pagesArray.isEmpty {
                Start(profile: profile)
            } else {
                AllSection(profile: profile)
                PagesSection(profile: profile)
            }
        }
        #if os(macOS)
        .safeAreaInset(edge: .bottom, alignment: .leading) {
            Button {
                withAnimation {
                    _ = Page.create(in: viewContext, profile: profile, prepend: true)

                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            } label: {
                Label {
                    Text("New Page", comment: "Button label.")
                } icon: {
                    Image(systemName: "plus.circle").imageScale(.medium)
                }
                .font(.body)
                .accessibilityIdentifier("new-page-button")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
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
            contentSelection = .search
        }
        #if os(iOS)
        .background(GroupedBackground())
        #endif
        .disabled(refreshManager.refreshing)
        .navigationTitle(profile.nameText)
        .toolbar {
            #if os(iOS)
            ToolbarItem {
                EditButton()
                    .buttonStyle(ToolbarButtonStyle())
                    .disabled(refreshManager.refreshing || profile.pagesArray.isEmpty)
                    .accessibilityIdentifier("edit-page-list-button")
            }
            ToolbarItem(placement: .bottomBar) {
                SettingsButton(showingSettings: $showingSettings).disabled(refreshManager.refreshing)
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                SidebarStatus(
                    profile: profile,
                    refreshing: $refreshManager.refreshing
                )
                .frame(maxWidth: .infinity)
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                RefreshButton(profile: profile)
                    .buttonStyle(PlainToolbarButtonStyle())
                    .disabled(
                        refreshManager.refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty
                    )
            }
            #else
            ToolbarItem {
                RefreshButton(profile: profile)
                    .buttonStyle(ToolbarButtonStyle())
                    .disabled(
                        refreshManager.refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty
                    )
            }
            ToolbarItem {
                if case .page(let page) = contentSelection {
                    AddFeedButton(page: page)
                        .buttonStyle(ToolbarButtonStyle())
                        .disabled(
                            refreshManager.refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty
                        )
                } else {
                    AddFeedButton()
                        .buttonStyle(ToolbarButtonStyle())
                        .disabled(
                            refreshManager.refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty
                        )
                }
                
            }
            #endif
        }
    }
}
