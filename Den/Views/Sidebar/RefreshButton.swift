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
    @Environment(NetworkMonitor.self) private var networkMonitor
    @Environment(RefreshManager.self) private var refreshManager
    
    var body: some View {
        Button {
            Task {
                await refreshManager.refresh()
            }
        } label: {
            Label {
                Text("Refresh", comment: "Button label.")
            } icon: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .keyboardShortcut("r", modifiers: [.command])
        .help(Text("Refresh Feeds", comment: "Button help text."))
        .accessibilityIdentifier("Refresh")
        .disabled(refreshManager.refreshing || !networkMonitor.isConnected)
    }
}
