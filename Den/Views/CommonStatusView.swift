//
//  CommonStatusView.swift
//  Den
//
//  Created by Garrett Johnson on 3/6/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

/**
 Common bottom bar with relative updated time and unread count.
 */
struct CommonStatusView: View {
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool

    @State private var refreshedDate: Date?
    @State private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    let unreadCount: Int
    var unreadLabel = "Unread"

    var body: some View {
        VStack {
            if refreshing {
                Text("Checking for New Items…")
            } else {
                if let refreshedDate = refreshedDate {
                    if -refreshedDate.timeIntervalSinceNow < 60 {
                        Text("Updated Just Now")
                    } else {
                        Text("Updated \(refreshedDate.formatted(.relative(presentation: .numeric, unitsStyle: .wide)))")
                    }
                }
                Text("\(unreadCount) \(unreadLabel)").foregroundColor(.secondary)
            }
        }
        .font(.caption)
        .lineLimit(1)
        .task {
            refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile)
        }
        .onReceive(timer) { _ in
            refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile)
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
        .onAppear {
            timer = self.timer.upstream.autoconnect()
        }
    }
}
