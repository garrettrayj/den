//
//  FeedOptionsSheet.swift
//  Den
//
//  Created by Garrett Johnson on 6/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed

    var body: some View {
        NavigationStack {
            ZStack {
                if feed.managedObjectContext == nil || feed.isDeleted {
                    Label {
                        Text("Feed Deleted", comment: "Object removed message.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                    .labelStyle(NoticeLabelStyle())
                } else {
                    FeedOptionsForm(feed: feed)
                }
            }
            .navigationTitle(Text("Feed Options", comment: "Navigation title."))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        viewContext.rollback()
                        dismiss()
                    } label: {
                        Text("Cancel", comment: "Button label.")
                    }
                    .accessibilityIdentifier("Cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Save", comment: "Button label.")
                    }
                    .accessibilityIdentifier("Save")
                }
            }
            .frame(minWidth: 360, minHeight: 480)
        }
    }
}
