//
//  RefreshButton.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RefreshButton: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile
    
    let progress = Progress()
    
    init(profile: Profile) {
        self.profile = profile
        self.progress.totalUnitCount = Int64(profile.feedsArray.count)
    }

    var body: some View {
        Button {
            Task {
                await refreshManager.refresh(profile: profile)
            }
        } label: {
            Label {
                Text("Refresh", comment: "Button label.")
            } icon: {
                if refreshManager.refreshing {
                    ProgressView(progress)
                        .progressViewStyle(CircularDeterminateProgressViewStyle())
                        #if os(macOS)
                        .frame(width: 18, height: 18)
                        #endif
                } else {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .accessibilityIdentifier("profile-refresh-button")
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
