//
//  SidebarStatus.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct SidebarStatus: View {
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool
    @Binding var refreshProgress: Progress

    var body: some View {
        Group {
            if !networkMonitor.isConnected {
                Text("Network offline", comment: "Status message.").foregroundStyle(.secondary)
            } else if refreshing {
                ProgressView(refreshProgress)
                    .progressViewStyle(RefreshProgressViewStyle(feedCount: profile.feedCount))
            } else if let refreshedDate = RefreshedDateStorage.getRefreshed(profile.id?.uuidString) {
                RelativeRefreshedDate(date: refreshedDate)
            } else if profile.pagesArray.isEmpty {
                Text("Profile empty", comment: "Status message.")
            } else {
                #if os(macOS)
                Text(
                    "Press \(Image(systemName: "command")) R to refresh",
                    comment: "Status message."
                )
                .imageScale(.small)
                #else
                Text("Pull to refresh", comment: "Status message.")
                #endif
            }
        }
        .lineLimit(1)
        .font(.caption)
        #if os(macOS)
        .padding(.horizontal, 4)
        #endif
    }
}
