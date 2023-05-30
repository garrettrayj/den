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
    @EnvironmentObject var networkMonitor: NetworkMonitor

    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool

    let progress: Progress

    var body: some View {
        VStack {
            if refreshing {
                ProgressView(progress).progressViewStyle(
                    BottomBarProgressViewStyle(profile: profile)
                )
            } else {
                if !profile.pagesArray.isEmpty {
                    if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
                        if refreshedDate.formatted(date: .complete, time: .omitted) ==
                            Date().formatted(date: .complete, time: .omitted) {
                            Text(
                                "Updated at \(refreshedDate.formatted(date: .omitted, time: .shortened))",
                                comment: "Profile status updated time shown on same day"
                            )
                        } else {
                            Text(
                                "Updated \(refreshedDate.formatted(date: .abbreviated, time: .omitted))",
                                comment: "Profile status updated date shown on days other than same day"
                            )
                        }
                    } else {
                        if networkMonitor.isConnected {
                            #if targetEnvironment(macCatalyst)
                            Text(
                                "Press \(Image(systemName: "command")) + R to Refresh",
                                comment: "Mac shortcut guidance note shown if last refreshed date is unknown"
                            ).imageScale(.small)
                            #else
                            Text(
                                "Pull to Refresh",
                                comment: "iOS shortcut guidance note shown if last refreshed date is unknown"
                            )
                            #endif
                        }
                    }

                    if !networkMonitor.isConnected {
                        Text("Network Offline", comment: "Sidebar status message").foregroundColor(.secondary)
                    }
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
    }
}
