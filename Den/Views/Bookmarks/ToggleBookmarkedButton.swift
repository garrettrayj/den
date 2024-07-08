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
            withAnimation {
                toggleBookmarked()
            }
        } label: {
            Label {
                Text("Bookmark")
            } icon: {
                Image(systemName: "bookmark")
                    .symbolVariant(item.wrappedBookmarked ? .slash : .none)
            }
        }
        .contentTransition(.symbolEffect(.replace))
    }
    
    private func toggleBookmarked() {
        if item.bookmarked == true {
            item.bookmarked = false
            item.bookmarks.forEach { modelContext.delete($0) }
        } else {
            item.bookmarked = true
            _ = Bookmark.create(in: modelContext, item: item)
        }
    }
}
