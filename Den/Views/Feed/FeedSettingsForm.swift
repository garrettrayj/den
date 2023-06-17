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
            FeedSettingsGeneralSection(feed: feed)
            FeedSettingsPreviewsSection(feed: feed)
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
