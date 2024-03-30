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
    @ObservedObject var item: Item
    @ObservedObject var feed: Feed

    var body: some View {
        ItemActionView(item: item, isLastInList: true, isStandalone: true) {
            VStack(alignment: .leading, spacing: 8) {
                FeedTitleLabel(feed: feed).font(.callout).imageScale(.small)
                
                VStack(alignment: .leading, spacing: 4) {
                    PreviewHeadline(title: item.titleText)
                    if !feed.hideBylines, let author = item.author {
                        PreviewAuthor(author: author)
                    }
                    if !item.bookmarks.isEmpty {
                        ItemTags(item: item)
                    }
                    if let date = item.published {
                        PreviewDateline(date: date)
                    }
                }
                
                if !feed.hideImages, let url = item.image {
                    LargeThumbnail(
                        url: url,
                        isRead: item.read,
                        sourceWidth: CGFloat(item.imageWidth),
                        sourceHeight: CGFloat(item.imageHeight)
                    )
                }
                
                if let teaser = item.teaser, teaser != "" && !feed.hideTeasers {
                    PreviewTeaser(teaser: teaser)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
    }
}
