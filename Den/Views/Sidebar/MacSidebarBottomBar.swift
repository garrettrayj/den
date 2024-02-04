//
//  MacSidebarBottomBar.swift
//  Den
//
//  Created by Garrett Johnson on 1/22/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct MacSidebarBottomBar: View {
    @Environment(\.displayScale) private var displayScale
    
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    
    @ObservedObject var profile: Profile
    
    @Binding var currentProfileID: String?
    @Binding var refreshing: Bool
    @Binding var refreshProgress: Progress
    
    let profiles: [Profile]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                ProfilePickerMenu(
                    profile: profile,
                    profiles: profiles,
                    currentProfileID: $currentProfileID
                )
                .disabled(refreshing)

                SidebarStatus(
                    profile: profile,
                    refreshing: $refreshing,
                    refreshProgress: $refreshProgress
                )
            }

            if refreshing {
                ProgressView(refreshProgress)
                    .progressViewStyle(.circular)
                    .labelsHidden()
                    .scaleEffect(1 / displayScale)
                    .frame(width: 18)
            } else {
                RefreshButton(profile: profile)
                    .labelStyle(.iconOnly)
                    .imageScale(.large)
                    .buttonStyle(.borderless)
                    .disabled(refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty)
            }
        }
        .padding(12)
        .padding(.top, 1)
        .background(alignment: .top) {
            Rectangle().fill(BackgroundSeparatorShapeStyle()).frame(height: 1)
        }
    }
}
