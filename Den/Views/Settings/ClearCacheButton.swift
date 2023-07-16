//
//  ClearCacheButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import SDWebImage

struct ClearCacheButton: View {
    @Binding var currentProfile: Profile?

    @State private var cacheSize: Int64 = 0

    let cacheSizeFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useAll
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true

        return formatter
    }()

    var body: some View {
        Button {
            Task {
                await resetFeeds()
                await emptyCache()
                cacheSize = 0
                currentProfile?.objectWillChange.send()
            }
        } label: {
            HStack {
                Label {
                    Text("Clear Cache", comment: "Button label.").fixedSize()
                } icon: {
                    Image(systemName: "clear")
                }
                Spacer()
                Text(verbatim: cacheSizeFormatter.string(fromByteCount: cacheSize))
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
        .task {
            await calculateCacheSize()
        }
        .disabled(cacheSize == 0)
        .accessibilityIdentifier("ClearCache")
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

    private func resetFeeds() async {
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
                RefreshedDateStorage.shared.setRefreshed(profile, date: nil)
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
}
