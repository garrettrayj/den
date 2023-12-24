//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson
//

import CoreData
import SwiftUI

struct FeedView: View {
    @Environment(\.minDetailColumnWidth) private var minDetailColumnWidth

    @ObservedObject var feed: Feed
    
    @SceneStorage("ShowingFeedInspector") private var showingInspector = false
    
    @AppStorage("HideRead") private var hideRead: Bool = false

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
            } else if let profile = feed.page?.profile {
                WithItems(
                    scopeObject: feed,
                    includeExtras: true
                ) { items in
                    FeedLayout(
                        feed: feed,
                        profile: profile,
                        hideRead: $hideRead,
                        items: items
                    )
                    .frame(minWidth: minDetailColumnWidth)
                    .toolbar {
                        FeedToolbar(
                            feed: feed,
                            hideRead: $hideRead,
                            showingInspector: $showingInspector,
                            items: items
                        )
                    }
                    .navigationTitle(feed.titleText)
                    .inspector(isPresented: $showingInspector) {
                        FeedInspector(feed: feed, profile: profile)
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
