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
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    var unreadLabel: Text

    let relativeDateStyle: Date.RelativeFormatStyle = .relative(presentation: .numeric, unitsStyle: .wide)

    var body: some View {
        VStack {
            if refreshManager.refreshing {
                Text("Checking for New Items…")
            } else {
                if refreshedLabel() != nil {
                    TimelineView(.everyMinute) { _ in
                        if let refreshedLabel = refreshedLabel() {
                            Text(refreshedLabel)
                        }
                    }
                }
                unreadLabel.foregroundColor(.secondary)
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
