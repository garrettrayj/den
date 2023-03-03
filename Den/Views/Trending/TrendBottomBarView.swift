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
        WithItems(scopeObject: trend) { _, items in
            FilterReadButtonView(hideRead: $hideRead) {
                trend.objectWillChange.send()
            }
            Spacer()
            Text("\(items.unread().count) Unread")
                .font(.caption)
                .fixedSize()
            Spacer()
            ToggleReadButtonView(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                trend.objectWillChange.send()
                if hideRead {
                    dismiss()
                }
            }
        }
    }
}
