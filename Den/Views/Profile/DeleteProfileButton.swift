//
//  DeleteProfileButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeleteProfileButton: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?

    @State private var showingAlert = false

    var body: some View {
        Button(role: .destructive) {
            showingAlert = true
        } label: {
            Label {
                Text("Delete Profile", comment: "Button label.").fixedSize()
            } icon: {
                Image(systemName: "person.crop.circle.badge.xmark")
            }
        }
        .alert(
            Text("Delete Profile?", comment: "Alert title."),
            isPresented: $showingAlert,
            actions: {
                Button(role: .cancel) {
                    // Pass
                } label: {
                    Text("Cancel", comment: "Button label.")
                }
                .accessibilityIdentifier("CancelDeleteProfile")

                Button(role: .destructive) {
                    delete()
                } label: {
                    Text("Delete", comment: "Button label.")
                }
                .accessibilityIdentifier("ConfirmDeleteProfile")
            },
            message: {
                Text(
                    "All profile content (pages, feeds, history, etc.) will be removed.",
                    comment: "Alert message."
                )
            }
        )
        .symbolRenderingMode(.multicolor)
        .accessibilityIdentifier("DeleteProfile")
    }

    private func delete() {
        for feedData in profile.feedsArray.compactMap({$0.feedData}) {
            viewContext.delete(feedData)
        }
        for trend in profile.trends {
            viewContext.delete(trend)
        }
        viewContext.delete(profile)
    }
}
