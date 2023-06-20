//
//  DeletePageButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeletePageButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var page: Page
    
    var dismiss: DismissAction?
    
    @State private var showingAlert: Bool = false

    var body: some View {
        Button(role: .destructive) {
            showingAlert = true
        } label: {
            Label {
                Text("Delete", comment: "Button label.").fixedSize()
            } icon: {
                Image(systemName: "trash")
            }
            .symbolRenderingMode(.multicolor)
        }
        .alert(
            Text("Delete Page?", comment: "Alert title."),
            isPresented: $showingAlert,
            actions: {
                Button(role: .cancel) { } label: {
                    Text("Cancel", comment: "Button label.")
                }
                .accessibilityIdentifier("cancel-button")
                
                Button(role: .destructive) {
                    Task {
                        page.feedsArray.forEach { feed in
                            if let feedData = feed.feedData {
                                viewContext.delete(feedData)
                            }
                        }
                        viewContext.delete(page)
                        dismiss?()
                    }
                } label: {
                    Text("Delete", comment: "Button label.")
                }
                .accessibilityIdentifier("delete-confirm-button")
            }
        )
        .accessibilityIdentifier("delete-page-button")
    }
}

