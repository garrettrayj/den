//
//  InboxBottomBarView.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct InboxBottomBarView: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let visibleItems: FetchedResults<Item>

    var body: some View {
        WithItems(scopeObject: profile, readFilter: false) { _, unreadItems in
            FilterReadButtonView(hideRead: $hideRead) {
                profile.objectWillChange.send()
            }
            Spacer()
            Text("\(unreadItems.count) Unread")
                .font(.caption)
                .fixedSize()
            Spacer()
            ToggleReadButtonView(unreadCount: unreadItems.count) {
                await HistoryUtility.toggleReadUnread(items: Array(visibleItems))
                profile.objectWillChange.send()
                for page in profile.pagesArray {
                    page.objectWillChange.send()
                }
            }
        }
    }
}
