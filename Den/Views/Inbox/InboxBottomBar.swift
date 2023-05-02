//
//  InboxBottomBar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct InboxBottomBar: ToolbarContent {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let items: FetchedResults<Item>

    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            FilterReadButton(hideRead: $hideRead) {
                profile.objectWillChange.send()
            }
        }
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            CommonStatus(profile: profile, unreadCount: items.unread().count)
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                profile.objectWillChange.send()
                for page in profile.pagesArray {
                    page.objectWillChange.send()
                }
            }
        }
    }
}
