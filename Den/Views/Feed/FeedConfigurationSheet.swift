//
//  FeedConfigurationSheet.swift
//  Den
//
//  Created by Garrett Johnson on 6/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedConfigurationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var feed: Feed

    var body: some View {
        NavigationStack {
            ZStack {
                if feed.managedObjectContext == nil || feed.isDeleted {
                    /* ERROR: Causes application to crash with:
                     "AttributeGraph: cycle detected through attribute 5216976"
                     repeating in logs
                     
                    ContentUnavailableView {
                        Label {
                            Text("Feed Deleted", comment: "Object removed message.")
                        } icon: {
                            Image(systemName: "trash")
                        }
                    }
                     */
                    Label {
                        Text("Feed Deleted", comment: "Object removed message.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                } else {
                    FeedConfigurationForm(feed: feed)
                }
            }
            .navigationTitle(Text("Feed Configuration", comment: "Navigation title."))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        Task {
                            viewContext.rollback()
                            dismiss()
                        }
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
            .frame(minWidth: 370, minHeight: 470)
        }
    }
}
