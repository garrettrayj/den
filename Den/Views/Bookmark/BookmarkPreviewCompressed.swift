//
//  BookmarkPreviewCompressed.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct BookmarkPreviewCompressed: View {
    @ObservedObject var bookmark: Bookmark
    @ObservedObject var feed: Feed

    var body: some View {
        VStack(spacing: 0) {
            FeedNavLink(feed: feed).buttonStyle(FeedTitleButtonStyle())
            BookmarkActionView(bookmark: bookmark) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        PreviewHeadline(title: bookmark.titleText)
                        if !feed.hideBylines, let author = bookmark.author {
                            PreviewAuthor(author: author)
                        }
                        if let date = bookmark.published {
                            PreviewDateline(date: date)
                        }
                    }
                    if !feed.hideImages, let url = bookmark.image {
                        Spacer()
                        SmallThumbnail(url: url, isRead: false)
                    } else {
                        Spacer(minLength: 0)
                    }
                }
                .padding(12)
            }
        }
    }
}
