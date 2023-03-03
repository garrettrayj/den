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

    var body: some View {
        WithItems(scopeObject: profile) { _, items in
            FilterReadButtonView(hideRead: $hideRead) {
                profile.objectWillChange.send()
            }
            Spacer()
            Text("\(items.unread().count) Unread")
                .font(.caption)
                .fixedSize()
            Spacer()
            ToggleReadButtonView(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                profile.objectWillChange.send()
                for page in profile.pagesArray {
                    page.objectWillChange.send()
                }
            }
        }
    }
}
