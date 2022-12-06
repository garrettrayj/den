//
//  NavigationListView.swift
//  Den
//
//  Created by Garrett Johnson on 10/8/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct NavigationListView: View {
    @Environment(\.persistentContainer) private var container
    
    @ObservedObject var profile: Profile
    
    let searchModel: SearchModel
    
    @Binding var selection: Panel?
    @Binding var refreshing: Bool

    var body: some View {
        List(selection: $selection) {
            InboxNavView(
                profile: profile,
                searchModel: searchModel,
                selection: $selection
            )
            TrendsNavView(profile: profile)
            Section {
                NewPageView(profile: profile)
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
                await RefreshUtility.refresh(container: container, profile: profile)
            }
        }
        #endif
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                editButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                AddFeedButtonView(selection: $selection)
            }
            ToolbarItem(placement: .bottomBar) {
                SettingsButtonView(selection: $selection)
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
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

    private func movePage( from source: IndexSet, to destination: Int) {
        var revisedItems = profile.pagesArray

        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }
        
        do {
            try container.viewContext.save()
            // Update array for UI
            profile.pagesArray = revisedItems
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    private func deletePage(indices: IndexSet) {
        indices.forEach {
            let page = profile.pagesArray[$0]
            for feed in page.feedsArray where feed.feedData != nil {
                container.viewContext.delete(feed.feedData!)
            }
            container.viewContext.delete(page)
        }
        
        do {
            try container.viewContext.save()
            NotificationCenter.default.post(name: .pagesRefreshed, object: profile.objectID)
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
