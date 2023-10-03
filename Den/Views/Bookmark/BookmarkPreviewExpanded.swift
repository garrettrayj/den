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
    @ObservedObject var bookmark: Bookmark
    @ObservedObject var feed: Feed

    var body: some View {
        VStack(spacing: 0) {
            FeedNavLink(feed: feed).buttonStyle(FeedTitleButtonStyle())
            BookmarkActionView(bookmark: bookmark) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        PreviewHeadline(title: bookmark.titleText)
                        if feed.hideBylines == false, let author = bookmark.author {
                            PreviewAuthor(author: author)
                        }
                        if let date = bookmark.published {
                            PreviewDateline(date: date)
                        }
                        if feed.hideImages != true, let url = bookmark.image {
                            LargeThumbnail(
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
                    Spacer(minLength: 0)
                }
                .padding()
            }
        }
    }
}
