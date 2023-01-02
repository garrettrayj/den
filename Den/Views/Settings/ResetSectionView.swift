//
//  ResetSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImage

struct ResetSectionView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var activeProfileID: String?
    @Binding var appProfileID: String?

    @ObservedObject var profile: Profile

    @State private var showingResetAlert = false
    @State private var cacheSize: Int64 = 0

    var cacheSizeFormatter: ByteCountFormatter {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useAll
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true

        return formatter
    }

    var body: some View {
        Section(header: Text("Reset")) {
            Button {
                Task {
                    await resetFeeds(profile: profile)
                    await emptyCache()
                    sleep(1)
                    await calculateCacheSize()
                    profile.objectWillChange.send()
                }
            } label: {
                HStack {
                    Text("Clear Cache")
                    Spacer()
                    Text(cacheSizeFormatter.string(fromByteCount: cacheSize))
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
            }
            .disabled(cacheSize == 0)
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
                    Task {
                        await resetEverything()
                        sleep(1)
                        await calculateCacheSize()
                    }
                    dismiss()
                }.accessibilityIdentifier("reset-confirm-button")
            }, message: {
                Text("All profiles will be removed. Default settings will be restored.")
            })
            .accessibilityIdentifier("reset-button")
        }
        .task {
            await calculateCacheSize()
        }
    }

    private func restoreUserDefaults() {
        // Clear our UserDefaults domain
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }

    private func emptyCache() async {
        await SDImageCache.shared.clear(with: .all)

        URLCache.shared.removeAllCachedResponses()
    }

    private func calculateCacheSize() async {
        let (_, imageCacheSize) = await SDImageCache.shared.calculateSize()

        let urlCacheSize = URLCache.shared.currentDiskUsage

        let cacheBytes = Int64(imageCacheSize) + Int64(urlCacheSize)

        cacheSize = cacheBytes > 1024 * 512 ? cacheBytes : 0
    }

    private func resetFeeds(profile: Profile) async {
        let container = PersistenceController.shared.container
        
        await container.performBackgroundTask { context in
            guard let profiles = try? context.fetch(Profile.fetchRequest()) as [Profile] else { return }
            for profile in profiles {
                for feedData in profile.feedsArray.compactMap({ $0.feedData }) {
                    context.delete(feedData)
                }
                profile.trends.forEach { trend in
                    context.delete(trend)
                }
            }
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        }
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
                let _ = ProfileUtility.createDefaultProfile(context: context)
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
        restoreUserDefaults()
    }
}
