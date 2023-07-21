//
//  InboxToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct InboxToolbar: CustomizableToolbarContent {
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let items: FetchedResults<Item>

    var body: some CustomizableToolbarContent {
        #if os(macOS)
        ToolbarItem(id: "InboxFilterRead") {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem(id: "InboxToggleRead") {
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                profile.objectWillChange.send()
                for page in profile.pagesArray {
                    page.objectWillChange.send()
                }
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(id: "InboxMenu", placement: .primaryAction) {
                Menu {
                    ToggleReadButton(unreadCount: items.unread().count) {
                        await HistoryUtility.toggleReadUnread(items: Array(items))
                        profile.objectWillChange.send()
                        for page in profile.pagesArray {
                            page.objectWillChange.send()
                        }
                    }
                    FilterReadButton(hideRead: $hideRead)
                } label: {
                    Label {
                        Text("Menu", comment: "Button label.")
                    } icon: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        } else {
            ToolbarItem(id: "InboxFilterRead", placement: .primaryAction) {
                FilterReadButton(hideRead: $hideRead)
            }
            ToolbarItem(id: "InboxToggleRead", placement: .primaryAction) {
                ToggleReadButton(unreadCount: items.unread().count) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                    profile.objectWillChange.send()
                    for page in profile.pagesArray {
                        page.objectWillChange.send()
                    }
                }
            }
        }
        #endif
    }
}
