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
    @Binding var showingInspector: Bool

    var body: some View {
        ZStack {
            if feed.managedObjectContext == nil || feed.isDeleted {
                ContentUnavailableView {
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
                }
            }
        }
        #if os(iOS)
        .background(Color(.systemGroupedBackground))
        #endif
    }
}
