//
//  PageBottomBarView.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct PageBottomBarView: View {
    @ObservedObject var page: Page

    @Binding var hideRead: Bool

    let visibleItems: FetchedResults<Item>

    var body: some View {
        WithItems(scopeObject: page, readFilter: false) { _, unreadItems in
            FilterReadButtonView(hideRead: $hideRead) {
                page.objectWillChange.send()
            }
            Spacer()
            Text("\(unreadItems.count) Unread").font(.caption).fixedSize()
            Spacer()
            ToggleReadButtonView(unreadCount: unreadItems.count) {
                await HistoryUtility.toggleReadUnread(items: Array(visibleItems))
                page.objectWillChange.send()
                page.feedsArray.forEach { $0.objectWillChange.send() }
            }
        }
    }
}
