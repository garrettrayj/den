//
//  BookmarkPreviewCompressed.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BookmarkPreviewCompressed: View {
    @ObservedObject var bookmark: Bookmark
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    var body: some View {
        VStack(spacing: 0) {
            FeedNavLink(feed: feed).buttonStyle(FeedTitleButtonStyle())
            Divider()
            BookmarkActionView(bookmark: bookmark, feed: feed) {
                HStack(alignment: .top) {
                    VStack(spacing: 4) {
                        PreviewHeadline(title: bookmark.titleText, browserView: feed.browserView)
                        if !feed.hideBylines, let author = bookmark.author {
                            PreviewAuthor(author: author)
                        }
                        if let date = bookmark.published {
                            PreviewDateline(date: date)
                        }
                    }
                    Spacer()
                    if !feed.hideImages, let url = bookmark.image {
                        PreviewThumbnail(url: url, isRead: false)
                    }
                }
                .padding()
            }
        }
        .modifier(RoundedContainerModifier())
    }
}
