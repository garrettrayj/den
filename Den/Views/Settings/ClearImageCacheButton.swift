//
//  ClearImageCacheButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI
import SDWebImage

struct ClearImageCacheButton: View {
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
                await emptyCache()
                cacheSize = 0
            }
        } label: {
            HStack {
                Label {
                    Text("Clear Image Cache", comment: "Button label.")
                } icon: {
                    Image(systemName: "square.3.layers.3d.down.right.slash")
                }
                Spacer()
                Text(
                    verbatim: ClearImageCacheButton.cacheSizeFormatter.string(
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
}
