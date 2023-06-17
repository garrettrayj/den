//
//  FeedSettingsForm.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedSettingsForm: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed

    var body: some View {
        Form {
            Section {
                TextField(text: $feed.wrappedTitle, prompt: Text("Untitled", comment: "Text field prompt.")) {
                    Label {
                        Text("Title", comment: "Text field label.")
                    } icon: {
                        Image(systemName: "character.cursor.ibeam")
                    }
                }
            } header: {
                #if os(iOS)
                Text("Title", comment: "Feed settings section header.")
                #endif
            }

            Section {
                Stepper(value: $feed.wrappedItemLimit, in: 1...100, step: 1) {
                    Text(
                        "Item Limit: \(feed.wrappedItemLimit)",
                        comment: "Stepper label."
                    )
                }
                #if os(iOS)
                .onChange(of: feed.wrappedItemLimit, perform: { _ in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                })
                #endif
            } header: {
                Text("Latest", comment: "Feed settings section header.")
            } footer: {
                if feed.changedValues().keys.contains("itemLimit") {
                    Text(
                        "Changes will be applied on next refresh.",
                        comment: "Item limit changed notice."
                    )
                }
            }

            PreviewsSection(feed: feed)
            MoveFeedSection(feed: feed)
        }
        .formStyle(.grouped)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle(Text("Feed Settings", comment: "Navigation title."))
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
