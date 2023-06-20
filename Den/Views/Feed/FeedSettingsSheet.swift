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
                if feed.managedObjectContext == nil || feed.isDeleted {
                    SplashNote(
                        title: Text("Feed Deleted", comment: "Object removed message."),
                        symbol: "slash.circle"
                    )
                } else {
                    FeedSettingsForm(feed: feed)
                }
            }
            .toolbar {
                ToolbarItem {
                    CloseButton(dismiss: dismiss)
                }
            }
            .frame(minWidth: 400, minHeight: 480)
        }
    }
}
