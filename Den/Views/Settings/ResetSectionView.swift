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
                    refreshCounts()
                }
            } label: {
                Text("Clear History")
            }
            .disabled(profile.history?.count == 0)
            .modifier(FormRowModifier())
            .accessibilityIdentifier("clear-history-button")

            Button {
                Task {
                    await resetFeeds(profile: profile)
                    refreshCounts()
                }
            } label: {
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
    
    private func refreshCounts() {
        DispatchQueue.main.async {
            profile.objectWillChange.send()
            for feed in profile.feedsArray {
                NotificationCenter.default.post(
                    name: .feedRefreshed,
                    object: feed.objectID,
                    userInfo: ["pageObjectID": feed.page?.objectID as Any]
                )
            }
            NotificationCenter.default.post(name: .pagesRefreshed, object: profile.objectID)
        }
    }

    private func resetHistory() async {
        await SyncUtility.resetHistory(container: container, profile: profile)
    }

    private func restoreUserDefaults() {
        // Clear our UserDefaults domain
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }

    private func resetFeeds(profile: Profile) async {
        await container.performBackgroundTask { context in
            guard let profile = context.object(with: profile.objectID) as? Profile else { return }
            
            profile.pagesArray.forEach { page in
                page.feedsArray.forEach { feed in
                    if let feedData = feed.feedData {
                        context.delete(feedData)
                    }
                }
            }
            
            profile.trends.forEach { trend in
                context.delete(trend)
            }
            
            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }

    private func resetEverything() {
        restoreUserDefaults()
        activeProfile = ProfileUtility.resetProfiles(context: container.viewContext)
    }
}
