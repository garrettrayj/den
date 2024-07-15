//
//  BookmarksNavDropDelegate.swift
//  Den
//
//  Created by Garrett Johnson on 9/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI
import UniformTypeIdentifiers

struct BookmarksNavDropDelegate: DropDelegate {
    let context: NSManagedObjectContext

    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: [.denItem]) else {
            return false
        }

        for provider in info.itemProviders(for: [.denItem]) {
            handleNewBookmark(provider)
        }

        return true
    }

    private func handleNewBookmark(_ provider: NSItemProvider) {
        _ = provider.loadTransferable(type: TransferableItem.self) { result in
            guard case .success(let transferableItem) = result else { return }

            Task {
                await MainActor.run {
                    guard
                        let objectID = context.persistentStoreCoordinator?.managedObjectID(
                            forURIRepresentation: transferableItem.objectURI
                        ),
                        let item = try? context.existingObject(with: objectID) as? Item
                    else { return }

                    _ = Bookmark.create(in: context, item: item)
                    item.bookmarked = true

                    do {
                        try context.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
        }
    }
}
