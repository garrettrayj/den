//
//  DeleteFeedButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeleteFeedButton: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed
    
    var body: some View {
        Button(role: .destructive) {
            viewContext.delete(feed)
        } label: {
            Label {
                Text("Delete Feed", comment: "Button label.")
            } icon: {
                Image(systemName: "minus.square")
            }
            .symbolRenderingMode(.multicolor)
        }
        .buttonStyle(.borderless)
        .accessibilityIdentifier("DeleteFeed")
    }
}
