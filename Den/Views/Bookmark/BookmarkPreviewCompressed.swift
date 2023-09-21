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
        VStack(alignment: .leading, spacing: 0) {
            FeedNavLink(feed: feed).buttonStyle(FeedTitleButtonStyle())
            Divider()
            BookmarkActionView(bookmark: bookmark, feed: feed, profile: profile) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        PreviewHeadline(title: bookmark.wrappedTitle, browserView: feed.browserView)
                        if feed.hideBylines == false, let author = bookmark.author {
                            PreviewAuthor(author: author)
                        }
                        VStack(alignment: .leading) {
                            PreviewDateline(date: bookmark.published)
                        }
                    }
                    Spacer()
                    if feed.hideImages != true, let url = bookmark.image {

                        PreviewThumbnail(url: url, isRead: false)
                    }
                }
                .padding()
            }
        }
        .modifier(RoundedContainerModifier())
    }
}
