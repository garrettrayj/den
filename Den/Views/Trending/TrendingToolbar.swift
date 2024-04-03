//
//  TrendingToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrendingToolbar: ToolbarContent {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    
    let trends: FetchedResults<Trend>

    private var unreadCount: Int {
        trends.containingUnread().count
    }

    private var itemsFromTrends: [Item] {
        return trends.flatMap { $0.items }.uniqueElements()
    }

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: unreadCount == 0) {
                await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                profile.objectWillChange.send()
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(placement: .bottomBar) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .status) {
                TrendingStatus(profile: profile, trends: trends)
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: unreadCount == 0) {
                    await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                    profile.objectWillChange.send()
                }
            }
        } else {
            ToolbarItem {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: unreadCount == 0) {
                    await HistoryUtility.toggleReadUnread(items: itemsFromTrends)
                    profile.objectWillChange.send()
                }
            }
        }
        #endif
    }
}
