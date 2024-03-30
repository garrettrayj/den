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

    var body: some View {
        BookmarkActionView(bookmark: bookmark) {
            VStack(alignment: .leading, spacing: 8) {
                Label {
                    bookmark.siteText
                } icon: {
                    Favicon(url: bookmark.favicon) {
                        BookmarkFaviconPlaceholder()
                    }
                }
                .font(.callout).imageScale(.small)
                
                VStack(alignment: .leading, spacing: 4) {
                    PreviewHeadline(title: bookmark.titleText)
                    if bookmark.hideByline == false, let author = bookmark.author {
                        PreviewAuthor(author: author)
                    }
                    if let date = bookmark.published {
                        PreviewDateline(date: date)
                    }
                }
                
                if bookmark.hideImage != true, let url = bookmark.image {
                    LargeThumbnail(
                        url: url,
                        isRead: false,
                        sourceWidth: CGFloat(bookmark.imageWidth),
                        sourceHeight: CGFloat(bookmark.imageHeight)
                    )
                }
                
                if let teaser = bookmark.teaser, teaser != "" && !bookmark.hideTeaser {
                    PreviewTeaser(teaser: teaser)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
    }
}
