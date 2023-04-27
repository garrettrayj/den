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
                ViewThatFits {
                    HStack(spacing: 4) {
                        if refreshedLabel() != nil {
                            TimelineView(.everyMinute) { _ in
                                if let refreshedLabel = refreshedLabel() {
                                    HStack(spacing: 4) {
                                        Text(refreshedLabel)
                                        Text("－").foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        Text("\(unreadCount) Unread").foregroundColor(.secondary)
                    }
                    VStack {
                        if refreshedLabel() != nil {
                            TimelineView(.everyMinute) { _ in
                                if let refreshedLabel = refreshedLabel() {
                                    Text(refreshedLabel)
                                    Text("－").foregroundColor(.secondary)
                                }
                            }
                        }
                        Text("\(unreadCount) Unread").foregroundColor(.secondary)
                    }
                }
            }
        }
        .font(.caption)
        .lineLimit(1)
    }

    private func refreshedLabel() -> String? {
        if let refreshedDate = feed.feedData?.refreshed {
            if -refreshedDate.timeIntervalSinceNow < 60 {
                return "Updated Just Now"
            }
            return "Updated \(refreshedDate.formatted(relativeDateStyle))"
        }
        return nil
    }
}
