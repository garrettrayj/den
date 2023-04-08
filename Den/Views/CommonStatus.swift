//
//  CommonStatus.swift
//  Den
//
//  Created by Garrett Johnson on 3/6/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

/**
 Common bottom bar with relative updated time and unread count.
 */
struct CommonStatus: View {
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool

    @State private var refreshedDate: Date?
    @State private var refreshedRelativeString: String?

    let unreadCount: Int
    var unreadLabel = "Unread"

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
                        Text("\(unreadCount) \(unreadLabel)").foregroundColor(Color(.secondaryLabel))
                    }
                    VStack {
                        if refreshedLabel() != nil {
                            TimelineView(.everyMinute) { _ in
                                if let refreshedLabel = refreshedLabel() {
                                    Text(refreshedLabel)
                                }
                            }
                        }
                        Text("\(unreadCount) \(unreadLabel)").foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .font(.caption)
        .lineLimit(1)
    }

    private func refreshedLabel() -> String? {
        if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
            if -refreshedDate.timeIntervalSinceNow < 60 {
                return "Updated Just Now"
            }
            return "Updated \(refreshedDate.formatted(relativeDateStyle))"
        }
        return nil
    }
}
