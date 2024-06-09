//
//  TagNavDropDelegate.swift
//  Den
//
//  Created by Garrett Johnson on 9/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct TagNavDropDelegate: DropDelegate {
    let modelContext: ModelContext
    let tag: Tag

    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: [.denBookmark, .denItem]) else {
            return false
        }

        for provider in info.itemProviders(for: [.denBookmark]) {
            handleMoveBookmark(provider)
        }

        for provider in info.itemProviders(for: [.denItem]) {
            handleNewBookmark(provider)
        }

        return true
    }

    private func handleMoveBookmark(_ provider: NSItemProvider) {
        _ = provider.loadTransferable(type: TransferableBookmark.self) { result in
            guard case .success(let transferableBookmark) = result else { return }

            Task {
                await MainActor.run {
                    guard
                        let bookmark = modelContext.model(
                            for: transferableBookmark.persistentModelID
                        ) as? Bookmark,
                        bookmark.tag != tag
                    else { return }

                    bookmark.tag = tag

                    do {
                        try modelContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
        }
    }

    private func handleNewBookmark(_ provider: NSItemProvider) {
        _ = provider.loadTransferable(type: TransferableItem.self) { result in
            guard case .success(let transferableItem) = result else { return }

            Task {
                await MainActor.run {
                    guard
                        let item = modelContext.model(
                            for: transferableItem.persistentModelID
                        ) as? Item,
                        !item.bookmarkTags.contains(tag)
                    else { return }

                    _ = Bookmark.create(in: modelContext, item: item, tag: tag)

                    do {
                        try modelContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
        }
    }
}
