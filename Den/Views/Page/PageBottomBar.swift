//
//  PageBottomBar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct PageBottomBar: View {
    @ObservedObject var page: Page
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool
    @Binding var hideRead: Bool

    var body: some View {
        WithItems(scopeObject: page) { items in
            HStack {
                FilterReadButton(hideRead: $hideRead) {
                    page.objectWillChange.send()
                }
                Spacer()
                CommonStatus(profile: profile, refreshing: $refreshing, unreadCount: items.unread().count)
                Spacer()
                ToggleReadButton(unreadCount: items.unread().count) {
                    await HistoryUtility.toggleReadUnread(items: Array(items))
                    page.objectWillChange.send()
                    page.feedsArray.forEach { $0.objectWillChange.send() }
                }
            }

        }
    }
}
