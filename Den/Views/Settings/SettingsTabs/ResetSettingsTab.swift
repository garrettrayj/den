//
//  ResetSettingsTab.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImage

struct ResetSettingsTab: View {
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
        VStack(alignment: .center) {
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
                    Label {
                        Text("Clear Cache", comment: "Button label.")
                    } icon: {
                        Image(systemName: "clear")
                    }
                    Text(verbatim: cacheSizeFormatter.string(fromByteCount: cacheSize))
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
                            sleep(1)
                            await calculateCacheSize()
                            dismiss()
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
        .padding()
        .task {
            await calculateCacheSize()
        }
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
