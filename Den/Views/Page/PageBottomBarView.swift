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

    @Binding var viewMode: Int
    @Binding var hideRead: Bool

    var unreadCount: Int {
        page.previewItems.unread().count
    }

    var body: some View {
        FilterReadButtonView(hideRead: $hideRead) {
            page.objectWillChange.send()
        }
        Spacer()
        Text("\(unreadCount) Unread").font(.caption).fixedSize()
        Spacer()
        ToggleReadButtonView(unreadCount: unreadCount) {
            await HistoryUtility.toggleReadUnread(items: page.previewItems)

            if viewMode == PageView.PageViewMode.blend.rawValue {
                // Send page update to refresh blend view
                page.objectWillChange.send()
            } else {
                // Send feed updates to refresh gadgets and showcase views
                for feed in page.feedsArray {
                    feed.objectWillChange.send()
                }
            }
        }
    }
}
