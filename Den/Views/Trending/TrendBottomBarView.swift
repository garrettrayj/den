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
    @ObservedObject var profile: Profile

    var refreshedDateTimeAgo: Date? {
        guard let refreshed = RefreshedDateStorage.shared.getRefreshed(profile) else { return nil }
        return refreshed
    }

    @State var refreshedDateTimeStr: String = "Loading..."

    @Binding var refreshing: Bool
    @Binding var hideRead: Bool

    var body: some View {
        WithItems(scopeObject: trend) { items in
            FilterReadButtonView(hideRead: $hideRead) {
                trend.objectWillChange.send()
            }
            Spacer()
            CommonStatusView(profile: profile, refreshing: $refreshing, unreadCount: items.unread().count)
            Spacer()
            ToggleReadButtonView(unreadCount: items.unread().count) {
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
