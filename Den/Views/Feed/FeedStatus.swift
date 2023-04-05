//
//  FeedStatus.swift
//  Den
//
//  Created by Garrett Johnson on 3/6/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedStatus: View {
    @ObservedObject var feed: Feed
    @Binding var refreshing: Bool

    let unreadCount: Int

    @State private var refreshedRelativeString: String?
    @State private var timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    let relativeDateStyle: Date.RelativeFormatStyle = .relative(presentation: .numeric, unitsStyle: .wide)

    var body: some View {
        VStack {
            if refreshing {
                Text("Checking for New Items…")
            } else {
                ViewThatFits {
                    HStack(spacing: 4) {
                        updatedText
                        Text("•").foregroundColor(Color(.secondaryLabel))
                        unreadText
                    }
                    VStack {
                        updatedText
                        unreadText
                    }
                }
            }
        }
        .font(.caption)
        .lineLimit(1)
        .onReceive(timer) { _ in
            updateRefreshedDateAndRelativeString()
        }
        .task {
            updateRefreshedDateAndRelativeString()
        }
        .onDisappear {
            self.timer.upstream.connect().cancel()
        }
        .onAppear {
            self.timer = self.timer.upstream.autoconnect()
        }
    }

    @ViewBuilder
    private var updatedText: some View {
        if
            let refreshedDate = feed.feedData?.refreshed,
            let refreshedRelativeString = refreshedRelativeString
        {
            if -refreshedDate.timeIntervalSinceNow < 60 {
                Text("Updated Just Now")
            } else {
                Text("Updated \(refreshedRelativeString)")
            }
        }
    }

    private var unreadText: some View {
        Text("\(unreadCount) Unread").foregroundColor(Color(.secondaryLabel))
    }

    private func updateRefreshedDateAndRelativeString() {
        if let refreshedDate = feed.feedData?.refreshed {
            self.refreshedRelativeString = refreshedDate.formatted(relativeDateStyle)
        }
    }
}
