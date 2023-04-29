//
//  FeedSettings.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedSettings: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed

    var body: some View {
        if feed.managedObjectContext == nil {
            SplashNote(title: "Feed Deleted", symbol: "slash.circle")
        } else {
            Form {
                Section(header: Text("Title").modifier(FirstFormHeaderModifier())) {
                    TextField("Title", text: $feed.wrappedTitle)
                        .modifier(FormRowModifier())
                        .modifier(TitleTextFieldModifier())
                }
                .modifier(ListRowModifier())

                PreviewsSection(feed: feed)
                MoveFeedSection(feed: feed)
                DeleteFeedButton(feed: feed)
            }
            .background(GroupedBackground())
            .onDisappear(perform: save)
            .navigationTitle("Feed Settings")
        }
    }

    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                feed.feedData?.itemsArray.forEach { item in
                    item.objectWillChange.send()
                }
                feed.objectWillChange.send()
                feed.page?.profile?.objectWillChange.send()
            } catch let error as NSError {
                CrashUtility.handleCriticalError(error)
            }
        }
    }
}
