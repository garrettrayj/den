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
    @ObservedObject var feed: Feed
    @Binding var refreshing: Bool

    let unreadCount: Int

    let relativeDateStyle: Date.RelativeFormatStyle = .relative(presentation: .numeric, unitsStyle: .wide)

    var body: some View {
        VStack {
            if refreshing {
                Text("Checking for New Items…")
            } else {
                ViewThatFits {
                    HStack(spacing: 4) {
                        if refreshedLabel() != nil {
                            TimelineView(.everyMinute) { _ in
                                if let refreshedLabel = refreshedLabel() {
                                    HStack(spacing: 4) {
                                        Text(refreshedLabel)
                                        Text("－").foregroundColor(Color(.secondaryLabel))
                                    }
                                }
                            }
                        }
                        Text("\(unreadCount) Unread").foregroundColor(Color(.secondaryLabel))
                    }
                    VStack {
                        if refreshedLabel() != nil {
                            TimelineView(.everyMinute) { _ in
                                if let refreshedLabel = refreshedLabel() {
                                    Text(refreshedLabel)
                                    Text("－").foregroundColor(Color(.secondaryLabel))
                                }
                            }
                        }
                        Text("\(unreadCount) Unread").foregroundColor(Color(.secondaryLabel))
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
