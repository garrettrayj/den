//
//  ReadingToolbarContent.swift
//  Den
//
//  Created by Garrett Johnson on 7/26/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ReadingToolbarContent: ToolbarContent {
    let items: [Item]
    let disabled: Bool

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
                Text("\(items.unread().count) Unread").font(.caption)
            }
            Spacer()
            Button(action: toggleAll) {
                Label(
                    "Mark All Read",
                    systemImage: items.unread().isEmpty ?
                        "checkmark.circle.fill" : "checkmark.circle"
                )
            }.accessibilityIdentifier("mark-all-read-button")
        }
    }
}
