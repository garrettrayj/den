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

struct InboxToolbar: ToolbarContent {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            CommonStatus(profile: profile)
        }
        ToolbarItem {
            FilterReadButton(hideRead: $hideRead)
        }
        ToolbarItem {
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                profile.objectWillChange.send()
                for page in profile.pagesArray {
                    page.objectWillChange.send()
                }
            }
        }
        #else
        ToolbarItem {
            Menu {
                ToggleReadButton(unreadCount: items.unread().count) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                    profile.objectWillChange.send()
                    for page in profile.pagesArray {
                        page.objectWillChange.send()
                    }
                }
                FilterReadButton(hideRead: $hideRead)
                NewFeedButton()
            } label: {
                Label {
                    Text("Menu", comment: "Menu button label.")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        #endif
    }
}
