//
//  ResetSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ResetSectionView: View {
    @Environment(\.persistentContainer) private var container
    @Environment(\.dismiss) private var dismiss

    @Binding var activeProfile: Profile?

    @ObservedObject var profile: Profile

    @State private var showingResetAlert = false

    var body: some View {
        Section(header: Text("Reset")) {
            Button {
                Task {
                    await resetHistory()
                }
            } label: {
                Text("Clear History")
            }
            .disabled(profile.history?.count == 0)
            .modifier(FormRowModifier())
            .accessibilityIdentifier("clear-history-button")

            Button(action: clearCache) {
                Text("Empty Cache")
            }
            .disabled(profile.feedsArray.compactMap({ $0.feedData }).isEmpty)
            .modifier(FormRowModifier())
            .accessibilityIdentifier("clear-cache-button")

            Button(role: .destructive) {
                showingResetAlert = true
            } label: {
                Text("Reset Everything")
                    .lineLimit(1)
                    .foregroundColor(.red)
            }
            .modifier(FormRowModifier())
            .alert("Reset Everything?", isPresented: $showingResetAlert, actions: {
                Button("Cancel", role: .cancel) { }.accessibilityIdentifier("reset-cancel-button")
                Button("Reset", role: .destructive) {
                    resetEverything()
                    dismiss()
                }.accessibilityIdentifier("reset-confirm-button")
            }, message: {
                Text("All profiles will be removed. Default settings will be restored.")
            })
            .accessibilityIdentifier("reset-button")
        }
    }

    private func resetHistory() async {
        await SyncUtility.resetHistory(container: container, profile: profile)
        DispatchQueue.main.async {
            profile.objectWillChange.send()
        }
    }

    private func clearCache() {
        resetFeeds()

        DispatchQueue.main.async {
            activeProfile?.objectWillChange.send()
        }
    }

    private func restoreUserDefaults() {
        // Clear our UserDefaults domain
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }

    private func resetFeeds() {
        guard let container = container else { return }
        
        do {
            let pages = try container.viewContext.fetch(Page.fetchRequest()) as [Page]
            pages.forEach { page in
                page.feedsArray.forEach { feed in
                    if let feedData = feed.feedData {
                        container.viewContext.delete(feedData)
                    }
                }
            }

            let trends = try container.viewContext.fetch(Trend.fetchRequest()) as [Trend]
            trends.forEach { trend in
                container.viewContext.delete(trend)
            }

            try container.viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    private func resetEverything() {
        guard let container = container else { return }
        restoreUserDefaults()
        activeProfile = ProfileUtility.resetProfiles(context: container.viewContext)
    }
}
