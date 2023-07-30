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

    @AppStorage("HideRead") private var hideRead: Bool = false

    @SceneStorage("ShowingFeedConfiguration") private var showingFeedConfiguration: Bool = false

    var body: some View {
        ZStack {
            if feed.managedObjectContext == nil || feed.isDeleted {
                SplashNote(
                    Text("Feed Deleted", comment: "Object removed message."),
                    icon: { Image(systemName: "xmark") }
                )
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
                    .toolbar(id: "Feed") {
                        FeedToolbar(
                            feed: feed,
                            profile: profile,
                            hideRead: $hideRead,
                            showingFeedConfiguration: $showingFeedConfiguration,
                            items: items
                        )
                    }
                    .navigationTitle(feed.titleText)
                }
            }
        }
        #if os(iOS)
        .background(Color(.systemGroupedBackground))
        #endif

        .sheet(
            isPresented: $showingFeedConfiguration,
            onDismiss: {
                DispatchQueue.main.async {
                    if viewContext.hasChanges {
                        do {
                            try viewContext.save()
                            feed.page?.profile?.objectWillChange.send()
                        } catch {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    }
                }
            },
            content: {
                FeedConfigurationSheet(feed: feed)
            }
        )
    }
}
