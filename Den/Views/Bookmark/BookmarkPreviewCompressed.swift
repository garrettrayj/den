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
                .font(.callout)
                .imageScale(.small)
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        PreviewHeadline(title: bookmark.titleText)
                        if !bookmark.hideByline, let author = bookmark.author {
                            PreviewAuthor(author: author)
                        }
                        if let date = bookmark.published {
                            PreviewDateline(date: date)
                        }
                    }
                    Spacer(minLength: 0)
                    if !bookmark.hideImage, let url = bookmark.image {
                        SmallThumbnail(url: url, isRead: false).padding(.leading, 12)
                    }
                }
            }
            .padding(12)
        }
    }
}
