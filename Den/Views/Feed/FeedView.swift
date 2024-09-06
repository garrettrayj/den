//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct FeedView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed
    
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
                .navigationTitle(Text(verbatim: ""))
            } else {
                WithItems(
                    scopeObject: feed,
                    includeExtras: true
                ) { items in
                    FeedLayout(
                        feed: feed,
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
                    .toolbar { toolbarContent(items: items) }
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

    #if os(macOS)
    @ToolbarContentBuilder
    private func toolbarContent(items: FetchedResults<Item>) -> some ToolbarContent {
        ToolbarItem {
            InspectorToggleButton(showingInspector: $showingInspector)
        }
        ToolbarItem {
            ToggleReadFilterButton()
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                HistoryUtility.toggleRead(items: items, context: viewContext)
            }
        }
    }
    #else
    @ToolbarContentBuilder
    private func toolbarContent(items: FetchedResults<Item>) -> some ToolbarContent {
        ToolbarTitleMenu {
            RenameButton()
            PagePicker(
                selection: $feed.page,
                labelText: Text("Move", comment: "Picker label.")
            ).pickerStyle(.menu)
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                DeleteLabel()
            }
        }

        if horizontalSizeClass == .compact {
            ToolbarItem {
                InspectorToggleButton(showingInspector: $showingInspector)
            }
            ToolbarItem(placement: .bottomBar) {
                ToggleReadFilterButton()
            }
            ToolbarItem(placement: .status) {
                CommonStatus()
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    HistoryUtility.toggleRead(items: items)
                }
            }
        } else {
            ToolbarItem {
                InspectorToggleButton(showingInspector: $showingInspector)
            }
            ToolbarItem {
                ToggleReadFilterButton()
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: items.unread.isEmpty) {
                    HistoryUtility.toggleRead(items: items)
                }
            }
        }
    }
    #endif
}
