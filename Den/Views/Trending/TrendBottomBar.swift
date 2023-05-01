//
//  TrendBottomBar.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct TrendBottomBar: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var trend: Trend
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    let items: FetchedResults<Item>

    var body: some View {
        HStack {
            FilterReadButton(hideRead: $hideRead) {
                trend.objectWillChange.send()
            }
            Spacer()
            CommonStatus(profile: profile, unreadCount: items.unread().count)
            Spacer()
            ToggleReadButton(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                trend.objectWillChange.send()
                profile.objectWillChange.send()
                if hideRead {
                    dismiss()
                }
            }
        }
    }
}
