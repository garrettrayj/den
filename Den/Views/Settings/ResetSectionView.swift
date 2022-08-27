//
//  ResetSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct ResetSectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var themeManager: ThemeManager

    @State var showingResetAlert = false

    var body: some View {
        Section(header: Text("Reset")) {
            Button(action: clearCache) {
                Label("Clear Cache", systemImage: "bin.xmark")
            }
            .modifier(FormRowModifier())
            .accessibilityIdentifier("clear-cache-button")

            Button(role: .destructive) {
                showingResetAlert = true
            } label: {
                Label("Reset Everything", systemImage: "clear")
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
                Text("All profiles, pages, feeds, and history will be permanently deleted.")
            })
            .accessibilityIdentifier("reset-button")
        }.modifier(SectionHeaderModifier())
    }

    private func clearCache() {
        guard let profile = profileManager.activeProfile else { return }
        refreshManager.cancel()
        resetFeeds()

        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()

        profile.objectWillChange.send()
        profile.pagesArray.forEach { $0.objectWillChange.send() }
    }

    private func restoreUserDefaults() {
        // Clear our UserDefaults domain
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()

        themeManager.objectWillChange.send()
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
                    profileManager.activeProfile?.objectWillChange.send()
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
        refreshManager.cancel()
        restoreUserDefaults()
        profileManager.resetProfiles()
    }
}
