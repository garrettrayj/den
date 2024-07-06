//
//  FeedItemExpanded.swift
//  Den
//
//  Created by Garrett Johnson on 1/28/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedItemExpanded: View {
    @Bindable var item: Item
    @Bindable var feed: Feed

    var body: some View {
        ItemActionView(item: item, isLastInList: true, isStandalone: true) {
            VStack(alignment: .leading, spacing: 8) {
                FeedTitleLabel(feed: feed).font(.callout).imageScale(.small)
                
                VStack(alignment: .leading, spacing: 4) {
                    PreviewHeadline(title: item.titleText)

                    if feed.showBylines, let author = item.author {
                        PreviewAuthor(author: author)
                    }
                    
                    ItemPreviewMeta(item: item)
                }
                
                if feed.showImages, let url = item.image {
                    LargeThumbnail(
                        url: url,
                        isRead: item.wrappedRead,
                        sourceWidth: CGFloat(item.imageWidth ?? 0),
                        sourceHeight: CGFloat(item.imageHeight ?? 0)
                    )
                }
                
                if let teaser = item.teaser, teaser != "" && feed.showExcerpts {
                    PreviewTeaser(teaser: teaser)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
    }
}
