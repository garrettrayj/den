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

struct InboxBottomBar: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var body: some View {
        FilterReadButton(hideRead: $hideRead) {
            profile.objectWillChange.send()
        }
        Spacer()
        WithItems(scopeObject: profile) { items in
            CommonStatus(profile: profile, unreadCount: items.unread().count)
            Spacer()
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
