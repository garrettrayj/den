//
//  EmptyCachesButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import SDWebImage

struct EmptyCachesButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var cacheSize: Int64 = 0

    static let cacheSizeFormatter: ByteCountFormatter = {
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
                clearFeedData()
                await emptyCache()
                cacheSize = 0
            }
        } label: {
            HStack {
                Label {
                    Text("Empty Caches", comment: "Button label.")
                } icon: {
                    Image(systemName: "xmark.bin")
                }
                Spacer()
                Text(
                    verbatim: EmptyCachesButton.cacheSizeFormatter.string(
                        fromByteCount: cacheSize
                    )
                )
                .font(.callout)
                .foregroundStyle(.secondary)
            }
        }
        .task {
            await calculateCacheSize()
        }
        .disabled(cacheSize == 0)
        .accessibilityIdentifier("EmptyCaches")
    }

    private func emptyCache() async {
        SDImageCache.shared.clearMemory()

        await SDImageCache.shared.clearDiskOnCompletion()

        URLCache.shared.removeAllCachedResponses()
    }
    
    private func clearFeedData() {
        guard let profiles = try? viewContext.fetch(Profile.fetchRequest()) as? [Profile] else {
            return
        }
        
        for profile in profiles {
            profile.feedsArray.compactMap { $0.feedData }.forEach { viewContext.delete($0) }
            RefreshedDateStorage.setRefreshed(profile.id?.uuidString, date: nil)
        }

        do {
            try viewContext.save()
            DispatchQueue.main.async {
                profiles.forEach { $0.objectWillChange.send() }
            }
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    private func calculateCacheSize() async {
        let (_, imageCacheSize) = await SDImageCache.shared.calculateSize()

        let urlCacheSize = URLCache.shared.currentDiskUsage

        let cacheBytes = Int64(imageCacheSize) + Int64(urlCacheSize)

        cacheSize = cacheBytes > 1024 * 512 ? cacheBytes : 0
    }
}
