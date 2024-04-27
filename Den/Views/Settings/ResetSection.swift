//
//  ResetSection.swift
//  Den
//
//  Created by Garrett Johnson on 10/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImage

struct ResetSection: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var cacheSize: Int64 = 0
    @State private var showingResetAlert = false
    
    @AppStorage("Refreshed") private var refreshedTimestamp: Double?
    
    @FetchRequest(sortDescriptors: [])
    private var history: FetchedResults<History>
    
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
                    Text(
                        verbatim: ResetSection.cacheSizeFormatter.string(fromByteCount: cacheSize)
                    )
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
                        Text("Clear Read History", comment: "Button label.")
                    } icon: {
                        Image(systemName: "clear")
                    }
                    Spacer()
                    Group {
                        if history.count == 1 {
                            Text("1 Record", comment: "History count (singular).")
                        } else {
                            Text("\(history.count) Records", comment: "History count (zeor/plural).")
                        }
                    }
                    .font(.callout)
                    .foregroundStyle(.secondary)
                }
            }
            .disabled(history.isEmpty)
            .accessibilityIdentifier("ClearHistory")
            
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
                        "All content will be deleted. Default settings will be restored.",
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
        PersistenceController.truncate(FeedData.self, context: viewContext)
        PersistenceController.truncate(Trend.self, context: viewContext)
        
        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
        
        refreshedTimestamp = nil
    }
    
    private func clearHistory() {
        PersistenceController.truncate(History.self, context: viewContext)

        if let items = try? viewContext.fetch(Item.fetchRequest()) {
            items.forEach { $0.read = false }
        }
        
        if let trends = try? viewContext.fetch(Trend.fetchRequest()) {
            trends.forEach { $0.read = false }
        }

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
    
    private func resetEverything() async {
        await MainActor.run {
            // Entities that may be cleared using the more performant batch truncate function.
            let batchTruncateList = [
                Blocklist.self,
                Item.self,
                Page.self,
                Tag.self,
                Trend.self,
                BlocklistStatus.self,
                FeedData.self,
                History.self
            ]
            
            batchTruncateList.forEach {
                PersistenceController.truncate($0, context: viewContext)
            }

            do {
                try viewContext.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
        
        await BlocklistManager.cleanupContentRulesLists()

        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        await emptyCaches()
    }

    private func calculateCacheSize() async {
        let (_, imageCacheSize) = await SDImageCache.shared.calculateSize()

        let urlCacheSize = URLCache.shared.currentDiskUsage

        let cacheBytes = Int64(imageCacheSize) + Int64(urlCacheSize)

        cacheSize = cacheBytes > 1024 * 512 ? cacheBytes : 0
    }
}
