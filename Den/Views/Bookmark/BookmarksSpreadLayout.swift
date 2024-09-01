//
//  BookmarksSpreadLayout.swift
//  Den
//
//  Created by Garrett Johnson on 2/19/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BookmarksSpreadLayout: View {
    let bookmarks: FetchedResults<Bookmark>
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                BoardView(width: geometry.size.width, list: Array(bookmarks)) { bookmark in
                    if bookmark.largePreview {
                        BookmarkPreviewExpanded(bookmark: bookmark)
                    } else {
                        BookmarkPreviewCompressed(bookmark: bookmark)
                    }
                }
                .drawingGroup()
            }
        }
    }
}
