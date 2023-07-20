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
    @Environment(\.displayScale) private var displayScale
    
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile
    
    @Binding var feedRefreshTimeout: Int
    @Binding var refreshing: Bool
    
    let refreshProgress: Progress

    var body: some View {
        Button {
            Task {
                await refreshManager.refresh(profile: profile, timeout: feedRefreshTimeout)
            }
        } label: {
            Label {
                Text("Refresh", comment: "Button label.")
            } icon: {
                #if os(macOS)
                if refreshing {
                    ProgressView(refreshProgress)
                        .progressViewStyle(.circular)
                        .labelsHidden()
                        
                        .scaleEffect(1 / displayScale)
                        
                        .frame(width: 16)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
                #else
                Image(systemName: "arrow.clockwise")
                #endif
            }
        }
        .keyboardShortcut("r", modifiers: [.command])
        .accessibilityIdentifier("Refresh")
    }
}
