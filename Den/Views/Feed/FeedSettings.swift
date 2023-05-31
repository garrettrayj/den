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
            SplashNote(title: Text("Feed Deleted", comment: "Object removed message"), symbol: "slash.circle")
        } else {
            Form {
                Section {
                    TextField(text: $feed.wrappedTitle, prompt: Text("Untitled", comment: "Text field prompt")) {
                        Text("Title", comment: "Text field label")
                    }
                    .modifier(FormRowModifier())
                    .modifier(TitleTextFieldModifier())
                } header: {
                    Text("Title", comment: "Feed settings section header").modifier(FirstFormHeaderModifier())
                }
                .modifier(ListRowModifier())

                Section {
                    Stepper(value: $feed.wrappedItemLimit, in: 1...100, step: 1) {
                        Text(
                            "Item Limit: \(feed.wrappedItemLimit)",
                            comment: "Stepper label"
                        )
                            .font(.callout)
                            .modifier(FormRowModifier())
                    }
                    .onChange(of: feed.wrappedItemLimit, perform: { _ in
                        Haptics.lightImpactFeedbackGenerator.impactOccurred()
                    })
                    .modifier(ListRowModifier())
                } header: {
                    Text("Latest", comment: "Feed settings section header")
                } footer: {
                    if feed.changedValues().keys.contains("itemLimit") {
                        Text(
                            "Changes will be applied on next refresh.",
                            comment: "Item limit changed notice"
                        )
                    }
                }

                PreviewsSection(feed: feed)
                MoveFeedSection(feed: feed)
                DeleteFeedButton(feed: feed)
            }
            .background(GroupedBackground())
            .onDisappear(perform: save)
            .navigationTitle(Text("Feed Settings", comment: "Navigation title"))
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
