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
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var contentSelection: ContentPanel?
    @Binding var searchQuery: String

    var body: some View {
        List(selection: $contentSelection) {
            if profile.pagesArray.isEmpty {
                Start(profile: profile)
            } else {
                InboxNav(
                    profile: profile,
                    contentSelection: $contentSelection,
                    searchQuery: $searchQuery
                )
                TrendingNav(profile: profile)
                Section {
                    ForEach(profile.pagesArray) { page in
                        PageNav(
                            profile: profile,
                            page: page
                        )
                    }
                    .onDelete(perform: deletePage)
                    .onMove(perform: movePage)
                } header: {
                    HStack {
                        Text("Pages")
                        Spacer()
                        AddPageButton(profile: profile)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        #if targetEnvironment(macCatalyst)
        .background(.regularMaterial)
        .navigationSplitViewColumnWidth(240)
        #else
        .navigationSplitViewColumnWidth(240 * dynamicTypeSize.layoutScalingFactor)
        .refreshable {
            if networkMonitor.isConnected {
                await refreshManager.refresh(profile: profile)
            }
        }
        #endif
        .disabled(refreshManager.refreshing)
        .navigationTitle(profile.displayName)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                editButton
                    .disabled(refreshManager.refreshing || profile.pagesArray.isEmpty)
            }
            ToolbarItem {
                AddFeedButton(contentSelection: $contentSelection)
                    .disabled(refreshManager.refreshing || profile.pagesArray.isEmpty || !networkMonitor.isConnected)
            }
            ToolbarItemGroup(placement: .bottomBar) {
                SettingsButton(listSelection: $contentSelection).disabled(refreshManager.refreshing)
                Spacer()
                SidebarStatus(
                    profile: profile,
                    refreshing: $refreshManager.refreshing,
                    progress: Progress(totalUnitCount: Int64(profile.feedsArray.count))
                )
                Spacer()
                RefreshButton(profile: profile)
                    .disabled(refreshManager.refreshing || profile.pagesArray.isEmpty || !networkMonitor.isConnected)
            }
        }
    }

    private var editButton: some View {
        EditButton()
            .buttonStyle(ToolbarButtonStyle())
            .disabled(refreshManager.refreshing || profile.pagesArray.isEmpty)
            .accessibilityIdentifier("edit-page-list-button")
    }

    private func movePage(from source: IndexSet, to destination: Int) {
        var revisedItems = profile.pagesArray

        // Change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // Update the userOrder attribute in revisedItems to persist the new order.
        // This is done in reverse order to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }

        do {
            try viewContext.save()
            profile.objectWillChange.send()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    private func deletePage(indices: IndexSet) {
        indices.forEach {
            viewContext.delete(profile.pagesArray[$0])
        }

        do {
            try viewContext.save()
            profile.objectWillChange.send()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
