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
    @EnvironmentObject var networkMonitor: NetworkMonitor

    let searchModel: SearchModel

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var contentSelection: ContentPanel?
    @Binding var refreshing: Bool

    @State private var searchInput: String = ""

    var body: some View {
        List(selection: $contentSelection) {
            if profile.pagesArray.isEmpty {
                Start(
                    profile: profile,
                    contentSelection: $contentSelection
                )
            } else {
                InboxNav(
                    profile: profile,
                    searchModel: searchModel,
                    contentSelection: $contentSelection
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
        .background(.thickMaterial)
        .navigationSplitViewColumnWidth(240)
        #else
        .navigationSplitViewColumnWidth(240 * dynamicTypeSize.layoutScalingFactor)
        .refreshable {
            if !refreshing && networkMonitor.isConnected {
                await RefreshUtility.refresh(profile: profile)
            }
        }
        #endif
        .disabled(refreshing)
        .navigationTitle(profile.displayName)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                editButton
                    .disabled(refreshing || profile.pagesArray.isEmpty)
            }
            ToolbarItem {
                AddFeedButton(contentSelection: $contentSelection, profile: profile)
                    .disabled(refreshing || profile.pagesArray.isEmpty || !networkMonitor.isConnected)
            }
            ToolbarItemGroup(placement: .bottomBar) {
                SettingsButton(listSelection: $contentSelection).disabled(refreshing)
                Spacer()
                SidebarStatus(
                    profile: profile,
                    refreshing: $refreshing,
                    progress: Progress(totalUnitCount: Int64(profile.feedsArray.count))
                )
                Spacer()
                RefreshButton(profile: profile, refreshing: $refreshing)
                    .disabled(refreshing || profile.pagesArray.isEmpty || !networkMonitor.isConnected)
            }
        }
    }

    private var editButton: some View {
        EditButton()
            .buttonStyle(ToolbarButtonStyle())
            .disabled(refreshing || profile.pagesArray.isEmpty)
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
