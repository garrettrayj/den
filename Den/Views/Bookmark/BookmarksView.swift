//
//  BookmarksView.swift
//  Den
//
//  Created by Garrett Johnson on 1/17/24.
//  Copyright © 2024 Garrett Johnson
//

import SwiftUI

struct BookmarksView: View {
    @FetchRequest(sortDescriptors: [])
    private var bookmarks: FetchedResults<Bookmark>
    
    @State private var selection: Bookmark.ID?
    
    var body: some View {
        VStack {
            Table(Array(bookmarks), selection: $selection) {
                TableColumn("Feed") { bookmark in
                    if let feed = bookmark.feed {
                        FeedTitleLabel(feed: feed)
                    }
                }
                TableColumn("Title", value: \.wrappedTitle)
                TableColumn("Tags") { bookmark in
                    ForEach(bookmark.tagsArray) { tag in
                        tag.displayName
                    }
                }
            }
        }
    }
}
