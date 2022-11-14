//
//  ToggleReadButtonView.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ToggleReadButtonView: View {
    @Binding var unreadCount: Int
    @Binding var refreshing: Bool
    
    let toggleAll: () async -> Void
    
    @State private var toggling = false
    
    var body: some View {
        Button {
            toggling = true
            Task {
                await toggleAll()
                toggling = false
            }
        } label: {
            if toggling {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
            } else if unreadCount == 0 {
                Label(
                    "Mark All Unread",
                    systemImage: "checkmark.circle.fill"
                )
            } else {
                Label(
                    "Mark All Read",
                    systemImage: "checkmark.circle"
                )
            }
        }
        .buttonStyle(ToolbarButtonStyle())
        .accessibilityIdentifier("mark-all-read-button")
        .disabled(refreshing || toggling)
    }
}
