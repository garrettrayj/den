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
                    .frame(width: 20, height: 20)
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
        .padding(.top, 1)
        .background(alignment: .top) {
            Rectangle().fill(BackgroundSeparatorShapeStyle()).frame(height: 1)
        }
    }
}
