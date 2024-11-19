//
//  BookmarkPreviewExpanded.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BookmarkPreviewExpanded: View {
    @ObservedObject var bookmark: Bookmark

    var body: some View {
        BookmarkActionView(bookmark: bookmark) {
            VStack(alignment: .leading, spacing: 4) {
                Label {
                    bookmark.siteText
                } icon: {
                    Favicon(url: bookmark.favicon) {
                        BookmarkFaviconPlaceholder()
                    }
                }
                .font(.subheadline.weight(.medium))
                .imageScale(.small)
                
                VStack(alignment: .leading, spacing: 2) {
                    PreviewHeadline(title: bookmark.titleText)
                    if let date = bookmark.published {
                        PreviewDateline(date: date)
                    }
                    if bookmark.wrappedHideByline == false, let author = bookmark.author {
                        PreviewAuthor(author: author)
                    }
                }
                if bookmark.wrappedHideImage != true, let url = bookmark.image {
                    LargeThumbnail(
                        url: url,
                        isRead: false,
                        sourceWidth: CGFloat(bookmark.imageWidth),
                        sourceHeight: CGFloat(bookmark.imageHeight)
                    )
                }
                if let teaser = bookmark.teaser, teaser != "" && !bookmark.wrappedHideTeaser {
                    PreviewTeaser(teaser: teaser)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
    }
}
