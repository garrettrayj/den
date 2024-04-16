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
    @EnvironmentObject private var refreshManager: RefreshManager
    
    let pages: FetchedResults<Page>
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(BackgroundSeparatorShapeStyle()).frame(height: 1)
            HStack {
                VStack(alignment: .leading) {
                    SidebarStatus(pages: pages)
                }
                
                Spacer()

                if refreshManager.refreshing {
                    ProgressView(refreshManager.progress)
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
                        .disabled(pages.isEmpty)
                }
            }
            .padding(12)
            .frame(height: 48)
        }
    }
}
