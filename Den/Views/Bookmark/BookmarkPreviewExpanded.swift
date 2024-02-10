//
//  BookmarkPreviewExpanded.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct BookmarkPreviewExpanded: View {
    @ObservedObject var bookmark: Bookmark
    @ObservedObject var feed: Feed

    var body: some View {
        BookmarkActionView(bookmark: bookmark) {
            VStack(alignment: .leading, spacing: 8) {
                NavigationLink(value: SubDetailPanel.feed(feed)) {
                    FeedTitleLabel(feed: feed).font(.callout).imageScale(.small)
                }
                .accessibilityIdentifier("FeedNavLink")
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 4) {
                    PreviewHeadline(title: bookmark.titleText)
                    if feed.hideBylines == false, let author = bookmark.author {
                        PreviewAuthor(author: author)
                    }
                    if let date = bookmark.published {
                        PreviewDateline(date: date)
                    }
                    
                }
                
                if feed.hideImages != true, let url = bookmark.image {
                    LargeThumbnail(
                        url: url,
                        isRead: false,
                        width: CGFloat(bookmark.imageWidth),
                        height: CGFloat(bookmark.imageHeight)
                    )
                }
                
                if let teaser = bookmark.teaser, teaser != "" && !feed.hideTeasers {
                    PreviewTeaser(teaser: teaser)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
    }
}
