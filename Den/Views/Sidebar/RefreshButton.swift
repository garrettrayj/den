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
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @EnvironmentObject private var refreshManager: RefreshManager
    
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
        .help(Text("Refresh feeds", comment: "Button help text."))
        .accessibilityIdentifier("Refresh")
        .disabled(refreshManager.refreshing || !networkMonitor.isConnected)
    }
}
