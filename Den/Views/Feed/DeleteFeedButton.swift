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

    var body: some View {
        Button(role: .destructive) {
            Task {
                viewContext.delete(feed)
                if let feedData = feed.feedData { viewContext.delete(feedData) }
                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        } label: {
            DeleteLabel()
        }
        .buttonStyle(.borderless)
        .accessibilityIdentifier("DeleteFeed")
    }
}
