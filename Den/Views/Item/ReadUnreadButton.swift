//
//  ReadUnreadButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/19/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ReadUnreadButton: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var item: Item

    var body: some View {
        if item.read {
            Button {
                HistoryUtility.markItemUnread(context: viewContext, item: item)
            } label: {
                Label {
                    Text("Mark Unread", comment: "Button label.")
                } icon: {
                    Image(systemName: "checkmark.circle.badge.xmark")
                }
            }
        } else {
            Button {
                HistoryUtility.markItemRead(context: viewContext, item: item)
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
