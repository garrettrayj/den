//
//  FeedSettingsSheet.swift
//  Den
//
//  Created by Garrett Johnson on 6/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if feed.managedObjectContext == nil {
                    SplashNote(
                        title: Text("Feed Deleted", comment: "Object removed message."),
                        symbol: "slash.circle"
                    )
                } else {
                    FeedSettingsForm(feed: feed)
                }
            }
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    DeleteFeedButton(feed: feed, dismiss: dismiss)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        Task {
                            viewContext.rollback()
                            dismiss()
                        }
                    } label: {
                        Text("Cancel", comment: "Button label.")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Save", comment: "Button label.")
                    }
                }
            }
            .frame(minWidth: 400, minHeight: 480)
        }
    }
}
