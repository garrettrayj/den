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
            if !tags.isEmpty {
                ForEach(tags) { tag in
                    if item.bookmarkTags.contains(tag) {
                        Button {
                            for bookmark in item.bookmarks where bookmark.tag == tag {
                                modelContext.delete(bookmark)
                            }
                        } label: {
                            Label { tag.displayName } icon: {
                                Image(systemName: "tag.fill")
                            }
                        }
                        .labelStyle(.titleAndIcon)
                        .accessibilityIdentifier("RemoveBookmark")
                    } else {
                        Button {
                            _ = Bookmark.create(in: modelContext, item: item, tag: tag)
                        } label: {
                            Label { tag.displayName } icon: {
                                Image(systemName: "tag")
                            }
                        }
                        .labelStyle(.titleAndIcon)
                        .accessibilityIdentifier("AddBookmark")
                    }
                }
            } else {
                Text("No Tags", comment: "Menu options unavailable message.")
            }
        } label: {
            Label {
                Text("Tags", comment: "Menu label.")
            } icon: {
                if item.bookmarks.count > 0 {
                    Image(systemName: "tag.fill")
                } else {
                    Image(systemName: "tag")
                }
            }
        }
        .menuIndicator(.hidden)
        .help(Text("Select Tags", comment: "Menu help text."))
        .accessibilityIdentifier("TagsMenu")
    }
}
