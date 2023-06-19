//
//  ResetEverythingButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import SDWebImage

struct ResetEverythingButton: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?

    @State private var showingResetAlert = false

    var body: some View {
        Button(role: .destructive) {
            showingResetAlert = true
        } label: {
            Label {
                Text("Reset Everything", comment: "Button label.").lineLimit(1)
            } icon: {
                Image(systemName: "arrow.counterclockwise").foregroundColor(.red)
            }
        }
        .alert(
            Text("Reset Everything?", comment: "Alert title."),
            isPresented: $showingResetAlert,
            actions: {
                Button(role: .cancel) {
                    // pass
                } label: {
                    Text("Cancel", comment: "Button label.")
                }
                .accessibilityIdentifier("reset-cancel-button")

                Button(role: .destructive) {
                    Task {
                        await resetEverything()
                    }
                } label: {
                    Text("Reset", comment: "Button label.")
                }
                .accessibilityIdentifier("reset-confirm-button")
            },
            message: {
                Text(
                    "All profiles will be removed. Default settings will be restored.",
                    comment: "Alert message."
                )
            }
        )
        .accessibilityIdentifier("reset-button")
    }

    private func emptyCache() async {
        SDImageCache.shared.clearMemory()
        await SDImageCache.shared.clearDiskOnCompletion()
        URLCache.shared.removeAllCachedResponses()
    }

    private func resetEverything() async {
        await emptyCache()

        let container = PersistenceController.shared.container
        await container.performBackgroundTask { context in
            do {
                let profiles = try context.fetch(Profile.fetchRequest()) as [Profile]
                for profile in profiles {
                    for feedData in profile.feedsArray.compactMap({ $0.feedData }) {
                        context.delete(feedData)
                    }
                    context.delete(profile)
                }
                try context.save()

                activeProfile = nil
                appProfileID = nil
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }

        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}
