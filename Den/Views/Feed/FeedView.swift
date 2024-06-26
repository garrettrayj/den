//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct FeedView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed
    
    @Binding var hideRead: Bool
    
    @State private var showingDeleteAlert = false
    
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
                    .frame(minWidth: 320)
                    .toolbar {
                        FeedToolbar(
                            feed: feed,
                            hideRead: $hideRead,
                            showingDeleteAlert: $showingDeleteAlert,
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
                    .alert(
                        Text("Delete Feed?", comment: "Alert title."),
                        isPresented: $showingDeleteAlert,
                        actions: {
                            Button(role: .cancel) {
                                // Pass
                            } label: {
                                Text("Cancel", comment: "Button label.")
                            }
                            DeleteFeedButton(feed: feed)
                        },
                        message: {
                            Text(
                                "This action cannot be undone.",
                                comment: "Delete feed alert message."
                            )
                        }
                    )
                    #endif
                }
            }
        }
        #if os(iOS)
        .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        #endif
    }
}
