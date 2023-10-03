//
//  TagView.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TagView: View {
    @ObservedObject var profile: Profile
    @ObservedObject var tag: Tag

    var body: some View {
        if tag.managedObjectContext == nil || tag.isDeleted {
            ContentUnavailableView {
                Label {
                    Text("Tag Deleted", comment: "Object removed message.")
                } icon: {
                    Image(systemName: "trash")
                }
            }
            .navigationTitle("")
        } else {
            Group {
                if tag.bookmarksArray.isEmpty {
                    ContentUnavailableView {
                        Label {
                            Text("No Bookmarks", comment: "Content unavailable title.")
                        } icon: {
                            Image(systemName: "bookmark")
                        }
                    }
                } else {
                    GeometryReader { geometry in
                        ScrollView {
                            BoardView(width: geometry.size.width, list: tag.bookmarksArray) { bookmark in
                                if let feed = bookmark.feed {
                                    if feed.wrappedPreviewStyle == .expanded {
                                        BookmarkPreviewExpanded(
                                            bookmark: bookmark,
                                            feed: feed
                                        )
                                    } else {
                                        BookmarkPreviewCompressed(
                                            bookmark: bookmark,
                                            feed: feed
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(tag.nameText)
        }
    }
}
