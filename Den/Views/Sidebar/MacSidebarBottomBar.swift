//
//  MacSidebarBottomBar.swift
//  Den
//
//  Created by Garrett Johnson on 1/22/24.
//  Copyright © 2024 Garrett Johnson
//

import SwiftUI

struct MacSidebarBottomBar: View {
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
            
            RefreshButton()
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .buttonStyle(.borderless)
                .disabled(refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty)
        }
        .padding(12)
        .padding(.top, 1)
        .background(alignment: .top) {
            Rectangle().fill(BackgroundSeparatorShapeStyle()).frame(height: 1)
        }
    }
}
