//
//  ResetSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ResetSectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @Binding var activeProfile: Profile?

    @State var showingResetAlert = false

    var body: some View {
        Section(header: Text("Reset")) {
            Button(action: clearCache) {
                Text("Cache")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("clear-cache-button")

            Button(role: .destructive) {
                showingResetAlert = true
            } label: {
                Text("Everything")
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

    private func clearCache() {
        RefreshManager.cancel()
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
                        CrashManager.handleCriticalError(error as NSError)
                    }
                }
            }
        } catch {
            CrashManager.handleCriticalError(error as NSError)
        }
    }

    private func resetEverything() {
        RefreshManager.cancel()
        restoreUserDefaults()
        activeProfile = ProfileManager.resetProfiles(context: viewContext)
    }
}
