//
//  TrendsBottomBarView.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct TrendsBottomBarView: View {
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool
    @Binding var hideRead: Bool

    var unreadCount: Int {
        profile.trends.containingUnread().count
    }

    var itemsFromTrends: [Item] {
        return profile.trends.flatMap { $0.items }
    }

    var body: some View {
        FilterReadButtonView(hideRead: $hideRead) { }
        Spacer()
        CommonStatusView(
            profile: profile,
            refreshing: $refreshing,
            unreadCount: unreadCount,
            unreadLabel: unreadCount == 1 ? "Trend with Unread" : "Trends with Unread"
        )
        Spacer()
        ToggleReadButtonView(unreadCount: unreadCount) {
            await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
            profile.objectWillChange.send()
        }
    }
}
