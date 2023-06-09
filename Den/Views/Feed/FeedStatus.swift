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
        VStack {
            if refreshManager.refreshing {
                Text("Checking for New Items…", comment: "Status message.")
            } else {
                if let refreshedDate = feed.feedData?.refreshed {
                    TimelineView(.everyMinute) { _ in
                        RelativeRefreshedDate(date: refreshedDate)
                    }
                }
                Text("\(unreadCount) Unread", comment: "Status message.").foregroundColor(.secondary)
            }
        }
        .font(.caption)
        .lineLimit(1)
    }
}
