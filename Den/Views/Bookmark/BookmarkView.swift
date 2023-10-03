//
//  BookmarkView.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BookmarkView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ObservedObject var bookmark: Bookmark

    var maxContentWidth: CGFloat {
        CGFloat(700) * dynamicTypeSize.layoutScalingFactor
    }

    var body: some View {
        if
            let url = bookmark.link,
            !bookmark.isDeleted && bookmark.managedObjectContext != nil {
            BrowserView(
                url: url,
                readerMode: bookmark.feed?.readerMode,
                extraToolbar: {
                    ToolbarItem {
                        DeleteBookmarkButton(bookmark: bookmark)
                    }
                }
            )
        } else {
            ContentUnavailableView {
                Label {
                    Text("Bookmark Deleted", comment: "Object removed message.")
                } icon: {
                    Image(systemName: "trash")
                }
            }
        }
    }
}
