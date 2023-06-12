//
//  FeedStatus.swift
//  Den
//
//  Created by Garrett Johnson on 3/6/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedStatus: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var feed: Feed

    let unreadCount: Int

    var body: some View {
        Group {
            if refreshManager.refreshing {
                Text("Checking for New Items…", comment: "Status message.")
            } else {
                ViewThatFits {
                    HStack(spacing: 0) {
                        if let refreshedDate = feed.feedData?.refreshed {
                            RelativeRefreshedDate(date: refreshedDate)
                            Text(verbatim: " - ").foregroundColor(.secondary)
                        }
                        Text("\(unreadCount) Unread", comment: "Status message.").foregroundColor(.secondary)
                    }
                    VStack {
                        if let refreshedDate = feed.feedData?.refreshed {
                            RelativeRefreshedDate(date: refreshedDate)
                        }
                        Text("\(unreadCount) Unread", comment: "Status message.").foregroundColor(.secondary)
                    }
                }
            }
        }
        .font(.caption)
        .lineLimit(1)
    }
}
