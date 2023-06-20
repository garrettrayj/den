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
                #if os(macOS)
                ToolbarItem(placement: .confirmationAction) {
                    CloseButton(dismiss: dismiss)
                }
                ToolbarItem(placement: .destructiveAction) {
                    DeleteFeedButton(feed: feed, dismiss: dismiss)
                }
                #else
                ToolbarItem {
                    CloseButton(dismiss: dismiss)
                }
                ToolbarItem(placement: .topBarLeading) {
                    DeleteFeedButton(feed: feed, dismiss: dismiss).buttonStyle(.borderless)
                }
                #endif
            }
            .frame(minWidth: 400, minHeight: 480)
        }
    }
}
