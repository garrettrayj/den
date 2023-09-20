//
//  BookmarkPreviewExpanded.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BookmarkPreviewExpanded: View {
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var bookmark: Bookmark
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FeedNavLink(feed: feed).buttonStyle(FeedTitleButtonStyle())
            Divider()
            BookmarkActionView(bookmark: bookmark, feed: feed, profile: profile) {
                VStack(alignment: .leading, spacing: 4) {
                    PreviewHeadline(title: bookmark.wrappedTitle, browserView: feed.browserView)
                    if feed.hideBylines == false, let author = bookmark.author {
                        PreviewAuthor(author: author)
                    }
                    PreviewDateline(date: bookmark.published)
                    if feed.hideImages != true, let url = bookmark.image {
                        PreviewImage(
                            url: url,
                            isRead: false,
                            width: CGFloat(bookmark.imageWidth),
                            height: CGFloat(bookmark.imageHeight)
                        )
                        .padding(.top, 4)
                    }
                    if let teaser = bookmark.teaser, teaser != "" && !feed.hideTeasers {
                        PreviewTeaser(teaser: teaser)
                    }
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding()
            }
        }
        .modifier(RoundedContainerModifier())
    }
}
