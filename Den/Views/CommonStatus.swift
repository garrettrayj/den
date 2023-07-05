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

struct CommonStatus: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    @ObservedObject var profile: Profile

    var body: some View {
        VStack {
            if !networkMonitor.isConnected {
                Text("Network Offline", comment: "Status message.")
            } else if  refreshManager.refreshing {
                Text("Checking for New Items…", comment: "Refresh in-progress label.")
            }
        }
        .font(.caption)
        .lineLimit(1)
        .frame(minWidth: 100)
        .padding(.horizontal, 8)
    }
}
