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
                    PageNavView(profile: profile, page: page)
                }
                .onDelete(perform: deletePage)
                .onMove(perform: movePage)
            } header: {
                Text("Pages")
            }
        }
        .navigationTitle(profile.displayName)
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            if !refreshing {
                await RefreshUtility.refresh(profile: profile)
            }
        }
        #endif
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                editButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                AddFeedButtonView(contentSelection: $contentSelection, profile: profile)
            }
            ToolbarItem(placement: .bottomBar) {
                SettingsButtonView(listSelection: $contentSelection)
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                AddPageButtonView(profile: profile)
            }
            ToolbarItem(placement: .bottomBar) {
                StatusView(
                    profile: profile,
                    refreshing: $refreshing,
                    progress: Progress(totalUnitCount: Int64(profile.feedsArray.count))
                )
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                RefreshButtonView(profile: profile)
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
