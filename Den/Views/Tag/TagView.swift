//
//  TagView.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct TagView: View {
    @ObservedObject var tag: Tag

    var body: some View {
        if tag.managedObjectContext == nil || tag.isDeleted {
            ContentUnavailable {
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
                    ContentUnavailable {
                        Label {
                            Text("No Items", comment: "Content unavailable title.")
                        } icon: {
                            Image(systemName: "tag")
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
