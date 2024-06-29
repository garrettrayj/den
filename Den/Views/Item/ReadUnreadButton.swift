//
//  ReadUnreadButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ReadUnreadButton: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var item: Item

    var body: some View {
        if item.wrappedRead {
            Button {
                HistoryUtility.markItemUnread(modelContext: modelContext, item: item)
            } label: {
                Label {
                    Text("Mark Unread", comment: "Button label.")
                } icon: {
                    Image(systemName: "checkmark.circle.badge.xmark")
                }
            }
        } else {
            Button {
                HistoryUtility.markItemRead(modelContext: modelContext, item: item)
            } label: {
                Label {
                    Text("Mark Read", comment: "Button label.")
                } icon: {
                    Image(systemName: "checkmark.circle")
                }
            }
        }
    }
}
