//
//  FeedSettingsGeneralSection.swift
//  Den
//
//  Created by Garrett Johnson on 4/29/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedSettingsGeneralSection: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed

    var body: some View {
        Section {
            TextField(text: $feed.wrappedTitle, prompt: Text("Untitled", comment: "Text field prompt.")) {
                Label {
                    Text("Title", comment: "Text field label.")
                } icon: {
                    Image(systemName: "character.cursor.ibeam")
                }
            }

            if let profile = feed.page?.profile {
                PagePicker(
                    profile: profile,
                    selection: $feed.page,
                    labelText: Text("Move To", comment: "Picker label.")
                )
                .onChange(of: feed.page) { newPage in
                    self.feed.userOrder = (newPage?.feedsUserOrderMax ?? 0) + 1
                }
            }

            DeleteFeedButton(feed: feed).buttonStyle(.plain)
        } footer: {
            if feed.changedValues().keys.contains("itemLimit") {
                Text(
                    "Changes will be applied on next refresh.",
                    comment: "Item limit changed notice."
                )
            }
        }
    }
}
