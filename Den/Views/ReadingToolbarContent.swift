//
//  ReadingToolbarContent.swift
//  Den
//
//  Created by Garrett Johnson on 7/26/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ReadingToolbarContent: ToolbarContent {
    @Binding var unreadCount: Int
    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    let centerLabel: Text
    let toggleAll: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                hideRead.toggle()
            } label: {
                Label(
                    "Filter Read",
                    systemImage: hideRead ?
                        "line.3.horizontal.decrease.circle.fill"
                        : "line.3.horizontal.decrease.circle"
                )
            }
            .buttonStyle(ToolbarButtonStyle())
            .disabled(refreshing)
            .accessibilityIdentifier("filter-read-button")
            Spacer()
            centerLabel.font(.caption).fixedSize()
            Spacer()
            Button(action: toggleAll) {
                if unreadCount == 0 {
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
            .disabled(refreshing)
            .accessibilityIdentifier("mark-all-read-button")
        }
    }
}
