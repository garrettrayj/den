//
//  FeedItemCompressed.swift
//  Den
//
//  Created by Garrett Johnson on 2/27/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedItemCompressed: View {
    @ObservedObject var item: Item
    @ObservedObject var feed: Feed

    var body: some View {
        ItemActionView(item: item, isLastInList: true, isStandalone: true) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    FeedTitleLabel(feed: feed).font(.callout).imageScale(.small)
                    
                    PreviewHeadline(title: item.titleText)
                    
                    if !feed.hideBylines, let author = item.author {
                        PreviewAuthor(author: author)
                    }
                    if !item.bookmarks.isEmpty {
                        ItemTags(item: item)
                    }
                    if let date = item.published {
                        PreviewDateline(date: date)
                    }                    }
                
                Spacer(minLength: 0)

                if !feed.hideImages, let url = item.image {
                    SmallThumbnail(url: url, isRead: item.read).padding(.leading, 12)
                }
            }
            .padding(12)
        }
    }
}
