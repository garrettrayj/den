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
    @Environment(\.modelContext) private var modelContext
    
    let trends: [Trend]

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FilterReadButton()
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: trends.containingUnread.isEmpty) {
                HistoryUtility.toggleReadUnread(modelContext: modelContext, items: trends.items)
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(placement: .bottomBar) {
                FilterReadButton()
            }
            ToolbarItem(placement: .status) {
                CommonStatus()
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: trends.containingUnread.isEmpty) {
                    HistoryUtility.toggleReadUnread(modelContext: modelContext, items: trends.items)
                }
            }
        } else {
            ToolbarItem {
                FilterReadButton()
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: trends.containingUnread.isEmpty) {
                    HistoryUtility.toggleReadUnread(modelContext: modelContext, items: trends.items)
                }
            }
        }
        #endif
    }
}
