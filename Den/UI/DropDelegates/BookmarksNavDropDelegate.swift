//
//  BookmarksNavDropDelegate.swift
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

struct BookmarksNavDropDelegate: DropDelegate {
    let modelContext: ModelContext

    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: [.denBookmark, .denItem]) else {
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
                        let item = modelContext.model(
                            for: transferableItem.persistentModelID
                        ) as? Item
                    else { return }

                    _ = Bookmark.create(in: modelContext, item: item)
                    item.bookmarked = true
                }
            }
        }
    }
}
