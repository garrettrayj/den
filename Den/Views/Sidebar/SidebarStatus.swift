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

    @Binding var refreshing: Bool
    @Binding var refreshProgress: Progress
    
    let pages: FetchedResults<Page>

    var body: some View {
        VStack {
            if !networkMonitor.isConnected {
                Text("Network Offline", comment: "Status message.").foregroundStyle(.secondary)
            } else if refreshing {
                ProgressView(refreshProgress)
                    .progressViewStyle(RefreshProgressViewStyle(feedCount: pages.feeds.count))
            } else if let refreshedDate = RefreshedDateStorage.getRefreshed() {
                RelativeRefreshedDate(date: refreshedDate)
            } else if pages.isEmpty {
                Text("No Pages", comment: "Status message.")
            } else {
                #if os(macOS)
                Text(
                    "Press \(Image(systemName: "command")) R to Refresh",
                    comment: "Status message."
                )
                .imageScale(.small)
                #else
                Text("Pull to Refresh", comment: "Status message.")
                #endif
            }
        }
        .lineLimit(2)
        .font(.caption)
    }
}
