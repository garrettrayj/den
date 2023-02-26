//
//  TrendBottomBarView.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct TrendBottomBarView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var trend: Trend

    @Binding var hideRead: Bool

    var body: some View {
        WithItems(scopeObject: trend, readFilter: false) { _, unreadItems in
            FilterReadButtonView(hideRead: $hideRead) {
                trend.objectWillChange.send()
            }
            Spacer()
            Text("\(unreadItems.count) unread")
                .font(.caption)
                .fixedSize()
            Spacer()
            ToggleReadButtonView(unreadCount: unreadItems.count) {
                await HistoryUtility.toggleReadUnread(items: trend.items)
                trend.objectWillChange.send()
                if hideRead {
                    dismiss()
                }
            }
        }
    }
}
