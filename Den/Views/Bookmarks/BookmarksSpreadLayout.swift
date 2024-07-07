//
//  BookmarksSpreadLayout.swift
//  Den
//
//  Created by Garrett Johnson on 2/19/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BookmarksSpreadLayout: View {
    let bookmarks: [Bookmark]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                BoardView(width: geometry.size.width, list: bookmarks) { bookmark in
                    if bookmark.largePreview == true {
                        BookmarkPreviewExpanded(bookmark: bookmark)
                    } else {
                        BookmarkPreviewCompressed(bookmark: bookmark)
                    }
                }
            }
        }
    }
}
