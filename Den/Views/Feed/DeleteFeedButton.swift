//
//  DeleteFeedButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/18/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct DeleteFeedButton: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    var body: some View {
        Button(role: .destructive) {
            if let feedData = feed.feedData {
                viewContext.delete(feedData)
            }
            viewContext.delete(feed)
            do {
                try viewContext.save()
                profile.objectWillChange.send()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        } label: {
            Label {
                Text("Delete Feed", comment: "Button label.")
            } icon: {
                Image(systemName: "trash")
            }
            .symbolRenderingMode(.multicolor)
        }
        .buttonStyle(.borderless)
        .accessibilityIdentifier("DeleteFeed")
    }
}
