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
    
    var body: some View {
        VStack {
            if !networkMonitor.isConnected {
                Text("Network Offline", comment: "Sidebar status message.").foregroundColor(.secondary)
            } else if  refreshManager.refreshing {
                Text("Checking for New Items…", comment: "Refresh in-progress label.")
            } else if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
                RelativeRefreshedDate(date: refreshedDate)
            }
        }
        .frame(minWidth: 100)
        .font(.caption)
        .lineLimit(1)
        .padding(.horizontal, 8)
    }
}
