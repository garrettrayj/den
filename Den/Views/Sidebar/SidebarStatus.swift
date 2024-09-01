//
//  SidebarStatus.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarStatus: View {
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @EnvironmentObject private var refreshManager: RefreshManager
    
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
