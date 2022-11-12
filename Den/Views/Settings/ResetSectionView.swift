//
//  ResetSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ResetSectionView: View {
    @Environment(\.persistentContainer) private var persistentContainer
    @Environment(\.managedObjectContext) private var viewContext
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
        guard let container = persistentContainer else { return }
        await SyncUtility.resetHistory(container: container, profile: profile)
        DispatchQueue.main.async {
            profile.objectWillChange.send()
            profile.pagesArray.forEach { page in
                NotificationCenter.default.post(name: .pageRefreshed, object: page.objectID)
            }
        }
    }

    private func clearCache() {
        resetFeeds()

        DispatchQueue.main.async {
            activeProfile?.objectWillChange.send()
            activeProfile?.pagesArray.forEach {
                NotificationCenter.default.post(name: .pageRefreshed, object: $0.objectID)
            }
        }
    }

    private func restoreUserDefaults() {
        // Clear our UserDefaults domain
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }

    private func resetFeeds() {
        do {
            let pages = try viewContext.fetch(Page.fetchRequest()) as [Page]
            pages.forEach { page in
                page.feedsArray.forEach { feed in
                    if let feedData = feed.feedData {
                        viewContext.delete(feedData)
                    }
                }
            }

            let trends = try viewContext.fetch(Trend.fetchRequest()) as [Trend]
            trends.forEach { trend in
                viewContext.delete(trend)
            }

            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch {
                    DispatchQueue.main.async {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    private func resetEverything() {
        restoreUserDefaults()
        activeProfile = ProfileUtility.resetProfiles(context: viewContext)
    }
}
