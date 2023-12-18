//
//  SidebarStatus.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct SidebarStatus: View {
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    @ObservedObject var profile: Profile

    let progress: Progress

    @Binding var refreshing: Bool

    var body: some View {
        Group {
            if !networkMonitor.isConnected {
                Text("Network Offline", comment: "Status message.").foregroundStyle(.secondary)
            } else if refreshing {
                ProgressView(progress)
                    .progressViewStyle(RefreshProgressViewStyle(feedCount: profile.feedCount))
            } else if let refreshedDate = RefreshedDateStorage.getRefreshed(profile) {
                RelativeRefreshedDate(date: refreshedDate)
            } else if profile.pagesArray.isEmpty {
                Text("Profile Empty", comment: "Status message.")
            } else {
                #if os(macOS)
                Text(
                    "Press \(Image(systemName: "command")) + R to refresh.",
                    comment: "Status message."
                )
                #else
                Text("Pull to Refresh", comment: "Status message.")
                #endif
            }
        }
        .font(.caption)
        #if os(macOS)
        .padding(.horizontal, 4)
        #endif
    }
}
