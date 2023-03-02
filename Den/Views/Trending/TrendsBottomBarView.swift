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

    @Binding var hideRead: Bool

    var unreadCount: Int {
        profile.trends.containingUnread().count
    }

    var itemsFromVisibleTrends: [Item] {
        if hideRead {
            return profile.trends.containingUnread().flatMap { $0.items }
        }

        return profile.trends.flatMap { $0.items }
    }

    var body: some View {
        FilterReadButtonView(hideRead: $hideRead) { }
        Spacer()
        if hideRead {
            Text("\(unreadCount) w/ Unread").font(.caption)
        } else {
            Text("\(unreadCount) Trends").font(.caption)
        }
        Spacer()
        ToggleReadButtonView(unreadCount: unreadCount) {
            await HistoryUtility.toggleReadUnread(items: itemsFromVisibleTrends)
            profile.objectWillChange.send()
        }
    }
}
