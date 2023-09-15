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
        } else {
            ZStack {
                GeometryReader { geometry in
                    ScrollView {
                        BoardView(geometry: geometry, list: tag.bookmarksArray) { bookmark in
                            if let feed = bookmark.feed {
                                if feed.wrappedPreviewStyle == .expanded {
                                    ExpandedBookmarkPreview(bookmark: bookmark, feed: feed, profile: profile)
                                } else {
                                    CompressedBookmarkPreview(bookmark: bookmark, feed: feed, profile: profile)
                                }
                            }
                        }
                        .modifier(MainBoardModifier())
                    }
                }
            }
            .navigationTitle(tag.nameText)
        }
    }
}
