//
//  SearchToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 4/12/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct SearchToolbar: ToolbarContent {
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @Binding var hideRead: Bool

    let query: String
    let items: [Item]

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: items.unread().count == 0) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(placement: .bottomBar) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .status) {
                Text("Results for “\(query)”", comment: "Bottom bar status.")
                    .font(.caption)
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: items.unread().count == 0) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                }
            }
        } else {
            ToolbarItem(placement: .primaryAction) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(placement: .primaryAction) {
                MarkAllReadUnreadButton(allRead: items.unread().count == 0) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                }
            }
            ToolbarItem(placement: .status) {
                Text("Results for “\(query)”", comment: "Bottom bar status.")
                    .font(.caption)
            }
        }
        #endif
    }
}
