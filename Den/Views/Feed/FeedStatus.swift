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

    let relativeDateStyle: Date.RelativeFormatStyle = .relative(presentation: .numeric, unitsStyle: .wide)

    var body: some View {
        VStack {
            if refreshManager.refreshing {
                Text("Checking for New Items…")
            } else {
                if let refreshedDate = feed.feedData?.refreshed {
                    TimelineView(.everyMinute) { _ in
                        if -refreshedDate.timeIntervalSinceNow < 60 {
                            Text("Updated Just Now")
                        } else {
                            Text("Updated \(refreshedDate.formatted(relativeDateStyle))")
                        }
                    }
                }
                Text("\(unreadCount) Unread").foregroundColor(.secondary)
            }
        }
        .font(.caption)
        .lineLimit(1)
    }
}
