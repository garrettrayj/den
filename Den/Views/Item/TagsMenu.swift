//
//  TagsMenu.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI

struct TagsMenu: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var item: Item
    
    @Query(sort: [
        SortDescriptor(\Tag.userOrder, order: .forward),
        SortDescriptor(\Tag.name, order: .forward)
    ])
    private var tags: [Tag]

    var body: some View {
        Menu {
            if tags.isEmpty {
                Text("No Tags", comment: "Menu options unavailable message.")
            } else {
                ForEach(tags) { tag in
                    Button {
                        toggleTag(tag: tag)
                    } label: {
                        Label { tag.displayName } icon: {
                            Image(systemName: "tag")
                                .symbolVariant(item.bookmarks.count > 0 ? .fill : .none)
                        }
                    }
                    .labelStyle(.titleAndIcon)
                    .accessibilityIdentifier("ToggleTag")
                }
            }
        } label: {
            Label {
                Text("Tags", comment: "Menu label.")
            } icon: {
                Image(systemName: "tag").symbolVariant(item.bookmarks.count > 0 ? .fill : .none)
            }
        }
        .menuIndicator(.hidden)
        .help(Text("Select Tags", comment: "Menu help text."))
        .accessibilityIdentifier("TagsMenu")
    }

    private func toggleTag(tag: Tag) {
        if item.bookmarkTags.contains(tag) {
            for bookmark in item.bookmarks where bookmark.tag == tag {
                modelContext.delete(bookmark)
            }
        } else {
            _ = Bookmark.create(in: modelContext, item: item, tag: tag)
        }
    }
}
