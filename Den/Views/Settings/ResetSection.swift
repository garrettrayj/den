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
    
    @Query()
    private var history: [History]
    
    @Query()
    private var searches: [Search]

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
                    Text(ResetSection.cacheSizeFormatter.string(fromByteCount: cacheSize))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .task { await calculateCacheSize() }
                }
            }
            .accessibilityIdentifier("EmptyCaches")
            
            Button {
                clearHistory()
            } label: {
                HStack {
                    Label {
                        Text("Clear History", comment: "Button label.")
                    } icon: {
                        Image(systemName: "clear")
                    }
                    Spacer()
                    Group {
                        if history.count == 1 {
                            Text("1 Record", comment: "History count (singular).")
                        } else {
                            Text("\(history.count) Records", comment: "History count (zero/plural).")
                        }
                    }
                    .font(.callout)
                    .foregroundStyle(.secondary)
                }
            }
            .disabled(history.isEmpty)
            .accessibilityIdentifier("ClearHistory")
            
            Button {
                clearSearches()
            } label: {
                Label {
                    Text("Clear Search Suggestions", comment: "Button label.")
                } icon: {
                    Image(systemName: "clear")
                }
            }
            .disabled(searches.isEmpty)
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
                        resetEverything()
                        cacheSize = 0
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
    
    private func clearData() {
        try? modelContext.delete(model: FeedData.self)
        try? modelContext.delete(model: Item.self)
        try? modelContext.delete(model: Trend.self)
        
        refreshedTimestamp = nil
    }
    
    private func clearHistory() {
        try? modelContext.delete(model: History.self)

        if let items = try? modelContext.fetch(FetchDescriptor<Item>()) {
            items.forEach { $0.read = false }
        }
        
        if let trends = try? modelContext.fetch(FetchDescriptor<Trend>()) {
            trends.forEach { $0.read = false }
        }
    }

    private func clearSearches() {
        try? modelContext.delete(model: Search.self)
    }

    private func resetEverything() {
        for model in DataController.shared.localModels + DataController.shared.cloudModels {
            do {
                try modelContext.delete(model: model)
            } catch {
                print(error)
            }
        }

        Task {
            await BlocklistManager.removeAllContentRulesLists()
            await emptyCaches()
        }

        UserDefaults.group.removePersistentDomain(forName: AppGroup.den.rawValue)
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
    }

    private func calculateCacheSize() async {
        let (_, imageCacheSize) = await SDImageCache.shared.calculateSize()

        let urlCacheSize = URLCache.shared.currentDiskUsage

        let cacheBytes = Int64(imageCacheSize) + Int64(urlCacheSize)

        cacheSize = cacheBytes > 1024 * 512 ? cacheBytes : 0
    }
}
