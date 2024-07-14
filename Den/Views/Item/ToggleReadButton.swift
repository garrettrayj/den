//
//  ToggleReadButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ToggleReadButton: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var item: Item

    var body: some View {
        Button {
            withAnimation {
                if item.wrappedRead {
                    HistoryUtility.markItemUnread(modelContext: modelContext, item: item)
                } else {
                    HistoryUtility.markItemRead(modelContext: modelContext, item: item)
                }
            }
        } label: {
            Label {
                if item.wrappedRead {
                    Text("Mark Unread", comment: "Button label.")
                } else {
                    Text("Mark Read", comment: "Button label.")
                }
            } icon: {
                if item.wrappedRead {
                    Image(systemName: "checkmark.circle.badge.xmark")
                } else {
                    Image(systemName: "checkmark.circle")
                }
            }
            .symbolRenderingMode(.multicolor)
        }
        .contentTransition(.symbolEffect(.replace))
        .accessibilityIdentifier("ToggleRead")
    }
}
