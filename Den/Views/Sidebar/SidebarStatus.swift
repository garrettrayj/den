//
//  SidebarStatus.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SidebarStatus: View {
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool

    let progress = Progress()

    let dateFormatter: DateFormatter = {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .none
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.locale = .current
        relativeDateFormatter.doesRelativeDateFormatting = true

        return relativeDateFormatter
    }()

    init(profile: Profile, refreshing: Binding<Bool>) {
        self.profile = profile
        _refreshing = refreshing

        self.progress.totalUnitCount = Int64(profile.feedsArray.count)
    }

    var body: some View {
        VStack {
            if !networkMonitor.isConnected {
                Text("Network Offline", comment: "Status message.").foregroundColor(.secondary)
            } else if refreshing {
                ProgressView(progress)
                    .progressViewStyle(BottomBarProgressViewStyle(profile: profile))
            } else {
                if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
                    RelativeRefreshedDate(date: refreshedDate)
                }
            }
        }
        .font(.caption)
        .multilineTextAlignment(.center)
        .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed)) { _ in
            progress.completedUnitCount += 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .pagesRefreshed)) { _ in
            progress.completedUnitCount += 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshFinished)) { _ in
            progress.completedUnitCount = 0
        }
    }
}
