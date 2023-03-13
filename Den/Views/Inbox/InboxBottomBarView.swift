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

    var refreshedDateTimeAgo: Date? {
        guard let refreshed = RefreshedDateStorage.shared.getRefreshed(profile) else { return nil }
        return refreshed
    }

    @State var refreshedDateTimeStr: String = "Loading..."

    @Binding var refreshing: Bool
    @Binding var hideRead: Bool

    var body: some View {
        WithItems(scopeObject: profile) { items in
            FilterReadButtonView(hideRead: $hideRead) {
                profile.objectWillChange.send()
            }
            Spacer()
            CommonStatusView(profile: profile, refreshing: $refreshing, unreadCount: items.unread().count)
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
