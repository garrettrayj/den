//
//  BottomBarSidebarStatus.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BottomBarSidebarStatus: View {
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    @ObservedObject var profile: Profile

    let progress: Progress

    @Binding var refreshing: Bool

    var body: some View {
        VStack {
            if !networkMonitor.isConnected {
                Text("Network Offline", comment: "Status message.").foregroundColor(.secondary)
            } else if refreshing {
                ProgressView(progress)
                    .progressViewStyle(BottomBarProgressViewStyle(profile: profile))
            } else if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
                RelativeRefreshedDate(date: refreshedDate)
            }
        }
        .font(.caption)
        .multilineTextAlignment(.center)
    }
}
