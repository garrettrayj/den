//
//  DeleteFeedSection.swift
//  Den
//
//  Created by Garrett Johnson on 4/29/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeleteFeedButton: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed

    @State private var showingAlert: Bool = false

    var body: some View {
        Button(role: .destructive) {
            showingAlert = true
        } label: {
            Label {
                Text("Delete", comment: "Button label.").fixedSize()
            } icon: {
                Image(systemName: "trash")
            }
            .symbolRenderingMode(.multicolor)
        }
        .alert(
            Text("Delete Feed?", comment: "Alert title."),
            isPresented: $showingAlert,
            actions: {
                Button(role: .cancel) {
                    // Pass
                } label: {
                    Text("Cancel", comment: "Button label.")
                }
                .accessibilityIdentifier("feed-delete-cancel-button")

                Button(role: .destructive) {
                    performDelete()
                } label: {
                    Text("Delete", comment: "Button label.")
                }
                .accessibilityIdentifier("feed-delete-confirm-button")
            }
        )
        .accessibilityIdentifier("delete-feed-button")
    }

    private func performDelete() {
        if let feedData = feed.feedData {
            viewContext.delete(feedData)
        }
        viewContext.delete(feed)

        do {
            try viewContext.save()
            feed.page?.profile?.objectWillChange.send()
            dismiss()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
