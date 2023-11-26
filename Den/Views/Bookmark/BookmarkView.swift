//
//  BookmarkView.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct BookmarkView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ObservedObject var bookmark: Bookmark

    var body: some View {
        if
            let url = bookmark.link,
            !bookmark.isDeleted && bookmark.managedObjectContext != nil 
        {
            BrowserView(
                url: url,
                useBlocklists: bookmark.feed?.useBlocklists,
                useReaderAutomatically: bookmark.feed?.readerMode,
                extraToolbar: {
                    #if os(macOS)
                    ToolbarItem {
                        UntagButton(bookmark: bookmark)
                    }
                    #else
                    ToolbarItem(placement: .bottomBar) {
                        UntagButton(bookmark: bookmark)
                    }
                    #endif
                }
            )
        } else {
            ContentUnavailable {
                Label {
                    Text("Bookmark Deleted", comment: "Object removed message.")
                } icon: {
                    Image(systemName: "trash")
                }
            }
        }
    }
}
