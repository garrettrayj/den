//
//  SimpleSidebarStatus.swift
//  Den
//
//  Created by Garrett Johnson on 3/6/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SimpleSidebarStatus: View {
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    @ObservedObject var profile: Profile
    
    @Binding var refreshing: Bool

    var body: some View {
        Group {
            if !networkMonitor.isConnected {
                Text("Network Offline", comment: "Status message.")
            } else if refreshing {
                Text("Checking for New Items…", comment: "Refresh in-progress label.")
            } else if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
                RelativeRefreshedDate(date: refreshedDate)
            }
        }
        .font(.caption)
        .lineLimit(1)
        .foregroundStyle(.secondary)
    }
}
