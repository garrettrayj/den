//
//  ToggleBookmarkedButton.swift
//  Den
//
//  Created by Garrett Johnson on 7/3/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ToggleBookmarkedButton: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var item: Item
    
    var body: some View {
        Button {
            toggleBookmarked()
        } label: {
            Label {
                if item.wrappedBookmarked {
                    Text("Delete Bookmark")
                } else {
                    Text("Add Bookmark")
                }
            } icon: {
                Image(systemName: "bookmark")
                    .symbolVariant(item.wrappedBookmarked ? .slash : .none)
            }
        }
    }
    
    private func toggleBookmarked() {
        if item.bookmarked == true {
            item.bookmarks.forEach { modelContext.delete($0) }
            item.bookmarked = false
        } else {
            _ = Bookmark.create(in: modelContext, item: item)
            item.bookmarked = true
        }
    }
}
