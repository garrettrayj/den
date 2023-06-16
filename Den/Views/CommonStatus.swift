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
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    @ObservedObject var profile: Profile
    
    @State var progress: Progress = Progress()
    
    init(profile: Profile) {
        self.profile = profile
        self.progress.totalUnitCount = Int64(profile.feedsArray.count)
    }

    var body: some View {
        VStack {
            if !networkMonitor.isConnected {
                Text("Network Offline", comment: "Sidebar status message.").foregroundColor(.secondary)
            } else if  refreshManager.refreshing {
                Text("Updating…", comment: "Refresh in-progress label.")
                ProgressView(progress)
                    .progressViewStyle(.linear)
                    .labelsHidden()
                    #if os(macOS)
                    .frame(height: 8)
                    #else
                    .frame(height: 4)
                    #endif
            } else if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
                RelativeRefreshedDate(date: refreshedDate)
            }
        }
        .frame(minWidth: 100)
        .font(.caption)
        .lineLimit(1)
        .padding(.horizontal, 8)
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
