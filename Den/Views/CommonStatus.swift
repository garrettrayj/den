//
//  CommonStatus.swift
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
struct CommonStatus: View {
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool

    @State private var refreshedDate: Date?
    @State private var refreshedRelativeString: String?
    @State private var timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    let unreadCount: Int
    var unreadLabel = "Unread"

    let relativeDateStyle: Date.RelativeFormatStyle = .relative(presentation: .numeric, unitsStyle: .wide)

    var body: some View {
        VStack {
            if refreshing {
                Text("Checking for New Items…")
            } else {
                ViewThatFits {
                    HStack(spacing: 4) {
                        if
                            let refreshedDate = refreshedDate,
                            let refreshedRelativeString = refreshedRelativeString
                        {
                            if -refreshedDate.timeIntervalSinceNow < 60 {
                                Text("Updated Just Now")
                            } else {
                                Text("Updated \(refreshedRelativeString)")
                            }
                            Text("－").foregroundColor(Color(.secondaryLabel))
                        }
                        Text("\(unreadCount) \(unreadLabel)").foregroundColor(Color(.secondaryLabel))
                    }
                    VStack {
                        if
                            let refreshedDate = refreshedDate,
                            let refreshedRelativeString = refreshedRelativeString
                        {
                            if -refreshedDate.timeIntervalSinceNow < 60 {
                                Text("Updated Just Now")
                            } else {
                                Text("Updated \(refreshedRelativeString)")
                            }
                        }
                        Text("\(unreadCount) \(unreadLabel)").foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .font(.caption)
        .lineLimit(1)
        .onReceive(timer) { _ in
            updateRefreshedDateAndRelativeString()
        }
        .task {
            updateRefreshedDateAndRelativeString()
        }
        .onChange(of: refreshing) { _ in
            updateRefreshedDateAndRelativeString()
        }
        .onDisappear {
            self.timer.upstream.connect().cancel()
        }
        .onAppear {
            self.timer = self.timer.upstream.autoconnect()
        }
    }

    private func updateRefreshedDateAndRelativeString() {
        if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
            self.refreshedDate = refreshedDate
            self.refreshedRelativeString = refreshedDate.formatted(relativeDateStyle)
        }
    }
}
