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
    @ObservedObject var item: Item

    var body: some View {
        Button {
            Task {
                await HistoryUtility.toggleReadUnread(items: [item])
            }
        } label: {
            if item.read {
                Label {
                    Text("Mark Unread", comment: "Button label.")
                } icon: {
                    Image(systemName: "checkmark.circle.badge.xmark")
                }
            } else {
                Label {
                    Text("Mark Read", comment: "Button label.")
                } icon: {
                    Image(systemName: "checkmark.circle")
                }
            }
        }
    }
}
