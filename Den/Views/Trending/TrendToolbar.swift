//
//  TrendToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct TrendToolbar: ToolbarContent {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var trend: Trend
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let items: [Item]

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread().count == 0) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                if hideRead {
                    dismiss()
                }
            }
        }
        #else
        ToolbarItem(placement: .bottomBar) {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem(placement: .status) {
            CommonStatus(profile: profile, items: items)
        }
        ToolbarItem(placement: .bottomBar) {
            MarkAllReadUnreadButton(allRead: items.unread().count == 0) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                if hideRead {
                    dismiss()
                }
            }
        }
        #endif
    }
}
