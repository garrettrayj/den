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

    @Binding var hideRead: Bool
    
    let trends: FetchedResults<Trend>

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: trends.containingUnread.isEmpty) {
                await HistoryUtility.toggleReadUnread(items: trends.items)
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(placement: .bottomBar) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .status) {
                CommonStatus()
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: trends.containingUnread.isEmpty) {
                    await HistoryUtility.toggleReadUnread(items: trends.items)
                }
            }
        } else {
            ToolbarItem {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: trends.containingUnread.isEmpty) {
                    await HistoryUtility.toggleReadUnread(items: trends.items)
                }
            }
        }
        #endif
    }
}
