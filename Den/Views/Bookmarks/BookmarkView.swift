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
        if bookmark.isDeleted || bookmark.id == nil {
            ContentUnavailable {
                Label {
                    Text("Bookmark Removed", comment: "Object removed message.")
                } icon: {
                    Image(systemName: "bookmark").symbolVariant(.slash)
                }
            }
        } else {
            BrowserView(browserViewModel: browserViewModel)
                .task {
                    browserViewModel.contentRuleLists = await BlocklistManager.getContentRuleLists()
                    browserViewModel.useBlocklists = bookmark.feed?.useBlocklists ?? true
                    browserViewModel.useReaderAutomatically = bookmark.feed?.readerMode ?? false
                    browserViewModel.allowJavaScript = bookmark.feed?.allowJavaScript ?? true

                    browserViewModel.loadURL(url: bookmark.link)
                }
                .toolbar {
                    BookmarkToolbar(bookmark: bookmark, browserViewModel: browserViewModel)
                }
        }
    }
}
