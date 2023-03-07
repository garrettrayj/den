//
//  NavigationListView.swift
//  Den
//
//  Created by Garrett Johnson on 10/8/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct NavigationListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    let searchModel: SearchModel

    @Binding var contentSelection: ContentPanel?
    @Binding var refreshing: Bool

    var body: some View {
        List(selection: $contentSelection) {
            InboxNavView(
                profile: profile,
                searchModel: searchModel,
                contentSelection: $contentSelection
            )
            TrendsNavView(profile: profile)
            Section {
                ForEach(profile.pagesArray) { page in
                    PageNavView(
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
                    AddPageButtonView(profile: profile)
                }

            }
        }
        .tint(profile.tintColor)
        .disabled(refreshing)
        .navigationTitle(profile.displayName)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                editButton.disabled(refreshing)
            }
            ToolbarItem {
                AddFeedButtonView(contentSelection: $contentSelection, profile: profile).disabled(refreshing)
            }
            ToolbarItemGroup(placement: .bottomBar) {
                SettingsButtonView(listSelection: $contentSelection).disabled(refreshing)
                Spacer()
                SidebarStatusView(
                    profile: profile,
                    refreshing: $refreshing,
                    progress: Progress(totalUnitCount: Int64(profile.feedsArray.count))
                )
                Spacer()
                RefreshButtonView(profile: profile, refreshing: $refreshing).disabled(refreshing)
            }
        }

    }

    private var editButton: some View {
        EditButton()
            .buttonStyle(ToolbarButtonStyle())
            .disabled(refreshing)
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
