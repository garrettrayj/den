//
//  PageNavDropDelegate.swift
//  Den
//
//  Created by Garrett Johnson on 8/29/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI
import UniformTypeIdentifiers

struct PageNavDropDelegate: DropDelegate {
    let context: NSManagedObjectContext
    let page: Page

    @Binding var newFeedPageObjectURL: URL?
    @Binding var newFeedWebAddress: String
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
                await moveFeedToPage(transferableFeed.objectURI)
            }
        }
    }
    
    private func moveFeedToPage(_ feedObjectURI: URL) {
        guard
            let objectID = context.persistentStoreCoordinator?.managedObjectID(
                forURIRepresentation: feedObjectURI
            ),
            let feed = try? context.existingObject(with: objectID) as? Feed,
            feed.page != page
        else { return }

        feed.page = page
        feed.userOrder = page.feedsUserOrderMax + 1

        do {
            try context.save()
            page.objectWillChange.send()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    private func handleNewFeed(_ provider: NSItemProvider) {
        if provider.canLoadObject(ofClass: URL.self) {
            _ = provider.loadObject(ofClass: URL.self, completionHandler: { url, _ in
                guard let url else { return }
                
                Task {
                    await showNewFeedSheet(url.absoluteString)
                }
            })
        } else if provider.canLoadObject(ofClass: String.self) {
            _ = provider.loadObject(ofClass: String.self, completionHandler: { droppedString, _ in
                guard let droppedString else { return }
                
                Task {
                    await showNewFeedSheet(droppedString)
                }
            })
        }
    }
    
    private func showNewFeedSheet(_ urlString: String) {
        newFeedPageObjectURL = page.objectID.uriRepresentation()
        newFeedWebAddress = urlString
        showingNewFeedSheet = true
    }
}
