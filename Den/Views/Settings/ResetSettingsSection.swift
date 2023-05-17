//
//  ResetSettingsSection.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImage

struct ResetSettingsSection: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var activeProfile: Profile?
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
                    Label("Clear Cache", systemImage: "clear")
                    Spacer()
                    Text(cacheSizeFormatter.string(fromByteCount: cacheSize))
                        .foregroundColor(.secondary)
                }
            }
            .disabled(cacheSize == 0)
            .modifier(FormRowModifier())
            .accessibilityIdentifier("clear-cache-button")

            Button(role: .destructive) {
                showingResetAlert = true
            } label: {
                Label {
                    Text("Reset Everything").lineLimit(1)
                } icon: {
                    Image(systemName: "arrow.counterclockwise").foregroundColor(.red)
                }
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
        .modifier(ListRowModifier())
    }

    private func emptyCache() async {
        SDImageCache.shared.clearMemory()

        await SDImageCache.shared.clearDiskOnCompletion()

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

        RefreshedDateStorage.shared.setRefreshed(profile, date: nil)
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
                let defaultProfile = ProfileUtility.createDefaultProfile(context: context)
                try context.save()

                activeProfile = defaultProfile
                appProfileID = defaultProfile.id?.uuidString
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }

        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}
