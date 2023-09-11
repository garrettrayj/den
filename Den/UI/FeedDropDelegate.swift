//
//  FeedDropDelegate.swift
//  Den
//
//  Created by Garrett Johnson on 8/29/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI
import UniformTypeIdentifiers

struct FeedDropDelegate: DropDelegate {
    let context: NSManagedObjectContext
    let page: Page

    @Binding var newFeedPageID: String?
    @Binding var newFeedWebAddress: String
    @Binding var showingNewFeedSheet: Bool

    var moveEnabled: Bool = true

    func performDrop(info: DropInfo) -> Bool {
        guard
            info.hasItemsConforming(to: [.feed, .url, .text]),
            let item = info.itemProviders(for: [.feed, .url, .text]).first
        else {
            return false
        }

        if item.hasItemConformingToTypeIdentifier(UTType.feed.identifier) && moveEnabled {
            handleMoveFeed(item: item)
        } else {
            handleNewFeed(item: item)
        }

        return true
    }

    private func handleMoveFeed(item: NSItemProvider) {
        _ = item.loadTransferable(type: TransferableFeed.self) { result in
            guard
                case .success(let transferableFeed) = result,
                let objectID = context.persistentStoreCoordinator?.managedObjectID(
                    forURIRepresentation: transferableFeed.objectURI
                ),
                let feed = try? context.existingObject(with: objectID) as? Feed,
                feed.page != page
            else { return }

            feed.page = page
            feed.userOrder = (feed.page?.feedsUserOrderMax ?? 0) + 1

            DispatchQueue.main.async {
                do {
                    try context.save()
                    page.profile?.objectWillChange.send()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        }
    }

    private func handleNewFeed(item: NSItemProvider) {
        if item.canLoadObject(ofClass: URL.self) {
            _ = item.loadObject(ofClass: URL.self, completionHandler: { url, _ in
                if let url = url {
                    newFeedPageID = page.id?.uuidString
                    newFeedWebAddress = url.absoluteStringForNewFeed
                    showingNewFeedSheet = true
                }
            })

            return
        }

        if item.canLoadObject(ofClass: String.self) {
            _ = item.loadObject(ofClass: String.self, completionHandler: { droppedString, _ in
                if let droppedString = droppedString {
                    newFeedPageID = page.id?.uuidString
                    newFeedWebAddress = droppedString
                    showingNewFeedSheet = true
                }
            })

            return
        }
    }
}
