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

    @SceneStorage("ShowingFeedSettings") private var showingSettings: Bool = false

    var body: some View {
        VStack {
            if feed.managedObjectContext == nil || feed.isDeleted {
                SplashNote(title: Text("Feed Deleted", comment: "Object removed message."))
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
                            showingSettings: $showingSettings,
                            items: items
                        )
                    }
                    .navigationTitle(feed.titleText)
                }
            }
        }
        .sheet(
            isPresented: $showingSettings,
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
            }
        ) {
            FeedConfigurationSheet(feed: feed)
        }
    }
}
