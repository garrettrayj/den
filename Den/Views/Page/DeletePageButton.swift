//
//  DeletePageButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeletePageButton: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var page: Page

    @State private var showingAlert: Bool = false

    var body: some View {
        Button(role: .destructive) {
            showingAlert = true
        } label: {
            Label {
                Text("Delete", comment: "Button label.")
            } icon: {
                Image(systemName: "trash")
            }
            .symbolRenderingMode(.multicolor)
            .fixedSize(horizontal: true, vertical: true)
        }
        .alert(
            Text("Delete Page?", comment: "Alert title."),
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
        .accessibilityIdentifier("delete-page-button")
    }

    private func performDelete() {
        page.feedsArray.forEach { feed in
            if let feedData = feed.feedData {
                viewContext.delete(feedData)
            }
            viewContext.delete(feed)
        }
        viewContext.delete(page)
        
        do {
            try viewContext.save()
            page.profile?.objectWillChange.send()
            dismiss()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
