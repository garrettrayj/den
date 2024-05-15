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
    @Environment(NetworkMonitor.self) private var networkMonitor
    @Environment(RefreshManager.self) private var refreshManager
    
    let feedCount: Int
    
    @AppStorage("Refreshed") private var refreshedTimestamp: Double?

    var body: some View {
        VStack {
            if !networkMonitor.isConnected {
                Text("Network Offline", comment: "Status message.").foregroundStyle(.secondary)
            } else if feedCount != 0 {
                if refreshManager.refreshing {
                    ProgressView(refreshManager.progress)
                        .progressViewStyle(RefreshProgressViewStyle(feedCount: feedCount))
                } else if let timestamp = refreshedTimestamp {
                    RelativeRefreshedDate(timestamp: timestamp)
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
        }
        .lineLimit(2)
        .font(.caption)
    }
}
