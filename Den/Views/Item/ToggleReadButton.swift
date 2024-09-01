//
//  ToggleReadButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/19/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ToggleReadButton: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var item: Item

    var body: some View {
        Button {
            if item.read {
                HistoryUtility.markItemUnread(context: viewContext, item: item)
            } else {
                HistoryUtility.markItemRead(context: viewContext, item: item)
            }
        } label: {
            Label {
                if item.read {
                    Text("Mark Unread", comment: "Button label.")
                } else {
                    Text("Mark Read", comment: "Button label.")
                }
            } icon: {
                if item.read {
                    Image(systemName: "checkmark.circle.badge.xmark")
                } else {
                    Image(systemName: "checkmark.circle")
                }
            }
        }
    }
}
