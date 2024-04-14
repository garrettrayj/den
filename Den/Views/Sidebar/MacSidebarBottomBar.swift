//
//  MacSidebarBottomBar.swift
//  Den
//
//  Created by Garrett Johnson on 1/22/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct MacSidebarBottomBar: View {
    @Environment(\.displayScale) private var displayScale
    
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    
    @Binding var refreshing: Bool
    @Binding var refreshProgress: Progress
    
    let pages: FetchedResults<Page>
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(BackgroundSeparatorShapeStyle()).frame(height: 1)
            HStack {
                VStack(alignment: .leading) {
                    SidebarStatus(
                        refreshing: $refreshing,
                        refreshProgress: $refreshProgress,
                        pages: pages
                    )
                }
                
                Spacer()

                if refreshing {
                    ProgressView(refreshProgress)
                        .progressViewStyle(.circular)
                        .labelsHidden()
                        .scaleEffect(1 / displayScale)
                        .frame(width: 18)
                        .offset(y: 1)
                } else {
                    RefreshButton()
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                        .fontWeight(.medium)
                        .buttonStyle(.borderless)
                        .disabled(refreshing || !networkMonitor.isConnected || pages.isEmpty)
                }
            }
            .padding(12)
            .frame(height: 48)
        }
    }
}
