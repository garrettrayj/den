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
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var profile: Profile

    var callback: () -> Void

    @State private var showingAlert = false

    var body: some View {
        Button(role: .destructive) {
            showingAlert = true
        } label: {
            Label {
                Text("Delete", comment: "Button label.")
            } icon: {
                Image(systemName: "trash")
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
                    Task {
                        await delete()
                        callback()
                    }
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
        .accessibilityIdentifier("delete-profile")
    }

    private func delete() async {
        let container = PersistenceController.shared.container

        await container.performBackgroundTask { context in
            if let toDelete = context.object(with: profile.objectID) as? Profile {
                for feedData in toDelete.feedsArray.compactMap({$0.feedData}) {
                    context.delete(feedData)
                }
                context.delete(toDelete)
            }
            do {
                try context.save()
            } catch let error as NSError {
                CrashUtility.handleCriticalError(error)
            }
        }
    }
}
