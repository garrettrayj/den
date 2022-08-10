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

    let toggleAll: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                withAnimation {
                    hideRead.toggle()
                }
            } label: {
                Label(
                    "Filter Read",
                    systemImage: hideRead ?
                        "line.3.horizontal.decrease.circle.fill"
                        : "line.3.horizontal.decrease.circle"
                )
            }
            Spacer()
            VStack {
                Text("\(unreadCount) Unread").font(.caption)
            }
            Spacer()
            Button(action: toggleAll) {
                Label(
                    "Mark All Read",
                    systemImage: unreadCount == 0 ?
                        "checkmark.circle.fill" : "checkmark.circle"
                )
            }.accessibilityIdentifier("mark-all-read-button")
        }
    }
}
