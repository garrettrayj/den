//
//  ResetSection.swift
//  Den
//
//  Created by Garrett Johnson on 10/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI

import SDWebImage

struct ResetSection: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var cacheSize: Int64 = 0
    @State private var showingResetAlert = false
    
    @AppStorage("Refreshed") private var refreshedTimestamp: Double?

    static let cacheSizeFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useAll
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true

        return formatter
    }()
    
    var body: some View {
        Section {
            Button {
                Task {
                    await clearData()
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
                    Text(ResetSection.cacheSizeFormatter.string(fromByteCount: cacheSize))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .task { await calculateCacheSize() }
                }
            }
            .accessibilityIdentifier("EmptyCaches")
            
            Button {
                Task {
                    await clearHistory()
                }
            } label: {
                Label {
                    Text("Clear History", comment: "Button label.")
                } icon: {
                    Image(systemName: "clear")
                }
            }
            .accessibilityIdentifier("ClearHistory")
            
            Button {
                Task {
                    await clearSearches()
                }
            } label: {
                Label {
                    Text("Clear Search Suggestions", comment: "Button label.")
                } icon: {
                    Image(systemName: "clear")
                }
            }
            .accessibilityIdentifier("ClearSearches")

            Button(role: .destructive) {
                showingResetAlert = true
            } label: {
                Label {
                    Text("Reset Everything", comment: "Button label.")
                } icon: {
                    Image(systemName: "arrow.counterclockwise").foregroundStyle(.red)
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
                    .accessibilityIdentifier("CancelReset")

                    Button(role: .destructive) {
                        Task {
                            await resetEverything()
                            cacheSize = 0
                        }
                    } label: {
                        Text("Reset", comment: "Button label.")
                    }
                    .accessibilityIdentifier("ConfirmReset")
                },
                message: {
                    Text(
                        "All data will be deleted. Default settings will be restored.",
                        comment: "Alert message."
                    )
                }
            )
            .accessibilityIdentifier("ResetEverything")
        } header: {
            Text("Reset", comment: "Settings section header.")
        }
    }
    
    private func emptyCaches() async {
        SDImageCache.shared.clearMemory()

        await SDImageCache.shared.clearDiskOnCompletion()

        URLCache.shared.removeAllCachedResponses()
    }
    
    private func clearData() async {
        let context = ModelContext(DataController.shared.container)
        
        try? context.fetch(FetchDescriptor<FeedData>()).forEach { context.delete($0) }
        try? context.fetch(FetchDescriptor<Trend>()).forEach { context.delete($0) }
        try? context.save()
        
        refreshedTimestamp = nil
        
        NotificationCenter.default.post(name: .rerender, object: nil)
    }
    
    private func clearHistory() async {
        let context = ModelContext(DataController.shared.container)
        
        try? context.fetch(FetchDescriptor<History>()).forEach { context.delete($0) }
        try? context.fetch(FetchDescriptor<Item>()).forEach { $0.read = false }
        try? context.fetch(FetchDescriptor<Trend>()).forEach { $0.read = false }
        try? context.save()
        
        NotificationCenter.default.post(name: .rerender, object: nil)
    }

    private func clearSearches() async {
        let context = ModelContext(DataController.shared.container)
        
        try? context.fetch(FetchDescriptor<History>()).forEach { context.delete($0) }
        try? context.save()
        
        NotificationCenter.default.post(name: .rerender, object: nil)
    }

    private func resetEverything() async {
        let context = ModelContext(DataController.shared.container)
        
        try? context.fetch(FetchDescriptor<Page>()).forEach { context.delete($0) }
        try? context.fetch(FetchDescriptor<FeedData>()).forEach { context.delete($0) }
        try? context.fetch(FetchDescriptor<Trend>()).forEach { context.delete($0) }
        try? context.fetch(FetchDescriptor<Bookmark>()).forEach { context.delete($0) }
        try? context.fetch(FetchDescriptor<History>()).forEach { context.delete($0) }
        try? context.fetch(FetchDescriptor<Search>()).forEach { context.delete($0) }
        try? context.fetch(FetchDescriptor<Blocklist>()).forEach { context.delete($0) }
        try? context.fetch(FetchDescriptor<BlocklistStatus>()).forEach { context.delete($0) }
        try? context.save()

        await BlocklistManager.removeAllContentRulesLists()
        await emptyCaches()

        UserDefaults.group.removePersistentDomain(forName: AppGroup.den.rawValue)
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
        
        NotificationCenter.default.post(name: .reset, object: nil)
    }

    private func calculateCacheSize() async {
        let (_, imageCacheSize) = await SDImageCache.shared.calculateSize()

        let urlCacheSize = URLCache.shared.currentDiskUsage

        let cacheBytes = Int64(imageCacheSize) + Int64(urlCacheSize)

        cacheSize = cacheBytes > 1024 * 512 ? cacheBytes : 0
    }
}
