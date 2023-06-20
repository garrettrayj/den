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
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    
    @State private var showingSettings: Bool = false

    var body: some View {
        if feed.managedObjectContext == nil {
            SplashNote(title: Text("Feed Deleted", comment: "Object removed message."), symbol: "slash.circle")
        } else {
            WithItems(
                scopeObject: feed,
                includeExtras: true
            ) { items in
                VStack {
                    FeedLayout(
                        feed: feed,
                        profile: profile,
                        hideRead: $hideRead,
                        items: items
                    )
                }
                .background(GroupedBackground())
                .toolbar {
                    FeedToolbar(
                        feed: feed,
                        profile: profile,
                        hideRead: $hideRead,
                        showingSettings: $showingSettings,
                        items: items
                    )
                }
                .navigationTitle(feed.titleText)
                .sheet(
                    isPresented: $showingSettings,
                    onDismiss: {
                        if viewContext.hasChanges {
                            do {
                                try viewContext.save()
                            } catch {
                                CrashUtility.handleCriticalError(error as NSError)
                            }
                        }
                    }
                ) {
                    FeedSettingsSheet(feed: feed)
                }
            }
        }
    }
}
