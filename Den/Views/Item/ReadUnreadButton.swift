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
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var item: Item
    @ObservedObject var profile: Profile

    var body: some View {
        if item.read {
            Button {
                HistoryUtility.markItemUnread(context: viewContext, item: item, profile: profile)
            } label: {
                Label {
                    Text("Mark Unread", comment: "Button label.")
                } icon: {
                    Image(systemName: "checkmark.circle.badge.xmark")
                }
            }
        } else {
            Button {
                HistoryUtility.markItemRead(context: viewContext, item: item, profile: profile)
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
