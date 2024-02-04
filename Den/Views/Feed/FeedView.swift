//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import CoreData
import SwiftUI

struct FeedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.minDetailColumnWidth) private var minDetailColumnWidth

    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile
    
    @Binding var hideRead: Bool
    
    @SceneStorage("ShowingFeedInspector") private var showingInspector = false

    var body: some View {
        Group {
            if feed.managedObjectContext == nil || feed.isDeleted {
                ContentUnavailable {
                    Label {
                        Text("Feed Deleted", comment: "Object removed message.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                }
                .navigationTitle("")
            } else if feed.feedData == nil || feed.feedData?.wrappedError != nil {
                FeedUnavailable(feed: feed, largeDisplay: true).navigationTitle(feed.displayTitle)
            } else {
                WithItems(
                    scopeObject: feed,
                    includeExtras: true
                ) { items in
                    FeedLayout(
                        feed: feed,
                        hideRead: $hideRead,
                        items: items
                    )
                    .onChange(of: feed.page) {
                        guard !feed.isDeleted else { return }

                        feed.userOrder = (feed.page?.feedsUserOrderMax ?? 0) + 1
                        do {
                            try viewContext.save()
                            feed.page?.objectWillChange.send()
                        } catch {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    }
                    .onChange(of: feed.title) {
                        guard !feed.isDeleted else { return }

                        do {
                            try viewContext.save()
                        } catch {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    }
                    .frame(minWidth: minDetailColumnWidth)
                    .toolbar {
                        FeedToolbar(
                            feed: feed,
                            profile: profile,
                            hideRead: $hideRead,
                            showingInspector: $showingInspector,
                            items: items
                        )
                    }
                    .navigationTitle(feed.displayTitle)
                    .navigationTitle($feed.wrappedTitle)
                    .inspector(isPresented: $showingInspector) {
                        FeedInspector(feed: feed)
                    }
                    #if os(iOS)
                    .toolbarBackground(.visible)
                    #endif
                }
            }
        }
        #if os(iOS)
        .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        #endif
    }
}
