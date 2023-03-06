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
    @ObservedObject var profile: Profile

    var refreshedDateTimeAgo: Date? {
        guard let refreshed = RefreshedDateStorage.shared.getRefreshed(profile) else { return nil }
        return refreshed
    }

    @State var refreshedDateTimeStr: String = "Loading..."

    @Binding var refreshing: Bool
    @Binding var hideRead: Bool

    var body: some View {
        let timer = Timer.publish(
            every: 1,
            on: .main,
            in: .common
        ).autoconnect()

        WithItems(scopeObject: page) { _, items in
            FilterReadButtonView(hideRead: $hideRead) {
                page.objectWillChange.send()
            }
            Spacer()
            VStack {
                if refreshing {
                    Text("Refreshing feeds...").font(.caption).fixedSize()
                } else if let refreshedDateTimeAgo = RefreshedDateStorage.shared.getRefreshed(profile) {
                    Text(refreshedDateTimeStr)
                        .font(.caption).fixedSize()
                        .multilineTextAlignment(TextAlignment.center)
                        .onReceive(timer) { (_) in
                            if -refreshedDateTimeAgo.timeIntervalSinceNow < 60 {
                                self.refreshedDateTimeStr = """
                                \(items.unread().count) unread.
                                Refreshed a few seconds ago.
                                """
                            } else {
                                self.refreshedDateTimeStr = """
                                \(items.unread().count) unread.
                                Refreshed \(refreshedDateTimeAgo.relativeTime()).
                                """
                            }
                        }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed)) { _ in
                self.refreshedDateTimeStr = "Refreshing feeds..."
            }
            Spacer()
            ToggleReadButtonView(unreadCount: items.unread().count) {
                await HistoryUtility.toggleReadUnread(items: Array(items))
                page.objectWillChange.send()
                page.feedsArray.forEach { $0.objectWillChange.send() }
            }
        }
    }
}
