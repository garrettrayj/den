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
    @Bindable var bookmark: Bookmark
    
    @State private var browserViewModel = BrowserViewModel()

    var body: some View {
        if
            let url = bookmark.link,
            !bookmark.isDeleted && bookmark.id != nil
        {
            BrowserView(
                url: url,
                useBlocklists: bookmark.feed?.useBlocklists,
                useReaderAutomatically: bookmark.feed?.readerMode,
                browserViewModel: browserViewModel
            )
            .toolbar {
                BookmarkToolbar(bookmark: bookmark, browserViewModel: browserViewModel)
            }
        } else {
            ContentUnavailable {
                Label {
                    Text("Bookmark Deleted", comment: "Object removed message.")
                } icon: {
                    Image(systemName: "bookmark").symbolVariant(.slash)
                }
            }
        }
    }
}
