//
//  PageNavDropDelegate.swift
//  Den
//
//  Created by Garrett Johnson on 8/29/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct PageNavDropDelegate: DropDelegate {
    let modelContext: ModelContext
    let page: Page

    @Binding var newFeedPageID: String?
    @Binding var newFeedURLString: String
    @Binding var showingNewFeedSheet: Bool

    func performDrop(info: DropInfo) -> Bool {
        if info.hasItemsConforming(to: [.denFeed]) {
            for provider in info.itemProviders(for: [.denFeed]) {
                handleMoveFeed(provider)
            }

            return true
        }

        if info.hasItemsConforming(to: [.url, .text])
            && !info.hasItemsConforming(to: [.denItem, .denBookmark]) {
            // Only recognize the first dropped item
            guard let provider = info.itemProviders(for: [.url, .text]).first else {
                return false
            }
            handleNewFeed(provider)

            return true
        }

        return false
    }

    private func handleMoveFeed(_ provider: NSItemProvider) {
        _ = provider.loadTransferable(type: TransferableFeed.self) { result in
            guard case .success(let transferableFeed) = result else { return }

            Task {
                await MainActor.run {
                    guard
                        let feed = modelContext.model(
                            for: transferableFeed.persistentModelID
                        ) as? Feed,
                        feed.page != page
                    else { return }
                    
                    feed.page = page
                    feed.userOrder = page.feedsUserOrderMax + 1

                    do {
                        try modelContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
        }
    }

    private func handleNewFeed(_ provider: NSItemProvider) {
        if provider.canLoadObject(ofClass: URL.self) {
            _ = provider.loadObject(ofClass: URL.self, completionHandler: { url, _ in
                if let url = url {
                    Task {
                        await MainActor.run {
                            newFeedPageID = page.id?.uuidString
                            newFeedURLString = url.absoluteStringForNewFeed
                            showingNewFeedSheet = true
                        }
                    }
                }
            })

            return
        }

        if provider.canLoadObject(ofClass: String.self) {
            _ = provider.loadObject(ofClass: String.self, completionHandler: { droppedString, _ in
                if let droppedString = droppedString {
                    Task {
                        await MainActor.run {
                            newFeedPageID = page.id?.uuidString
                            newFeedURLString = droppedString
                            showingNewFeedSheet = true
                        }
                    }
                }
            })

            return
        }
    }
}
