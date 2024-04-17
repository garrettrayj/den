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
    
    @AppStorage("Refreshed") private var refreshedTimestamp: Double?

    static let cacheSizeFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useAll
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true

        return formatter
    }()
    
    @FetchRequest(sortDescriptors: [])
    private var feedDatas: FetchedResults<FeedData>

    var body: some View {
        Button {
            Task {
                clearData()
                await emptyCaches()
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

    private func emptyCaches() async {
        SDImageCache.shared.clearMemory()

        await SDImageCache.shared.clearDiskOnCompletion()

        URLCache.shared.removeAllCachedResponses()
    }
    
    private func clearData() {
        if let feedDatas = try? viewContext.fetch(FeedData.fetchRequest()) {
            feedDatas.forEach { viewContext.delete($0) }
        }
        
        if let trends = try? viewContext.fetch(Trend.fetchRequest()) {
            trends.forEach { viewContext.delete($0) }
        }

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
        
        refreshedTimestamp = nil
    }

    private func calculateCacheSize() async {
        let (_, imageCacheSize) = await SDImageCache.shared.calculateSize()

        let urlCacheSize = URLCache.shared.currentDiskUsage

        let cacheBytes = Int64(imageCacheSize) + Int64(urlCacheSize)

        cacheSize = cacheBytes > 1024 * 512 ? cacheBytes : 0
    }
}
