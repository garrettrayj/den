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

    var body: some View {
        WithItems(scopeObject: page) { _, items in
            FilterReadButtonView(hideRead: $hideRead) {
                page.objectWillChange.send()
            }
            Spacer()
            Text("\(items.unread().count) Unread").font(.caption).fixedSize()
            Spacer()
            ToggleReadButtonView(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                page.objectWillChange.send()
                page.feedsArray.forEach { $0.objectWillChange.send() }
            }
        }
    }
}
