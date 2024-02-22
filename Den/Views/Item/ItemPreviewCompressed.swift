//
//  ItemPreviewCompressed.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct ItemPreviewCompressed: View {
    @ObservedObject var item: Item
    @ObservedObject var feed: Feed

    var body: some View {
        HStack(alignment: .top) {
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
            
            Spacer(minLength: 0)

            if !feed.hideImages, let url = item.image {
                SmallThumbnail(url: url, isRead: item.read).padding(.leading, 12)
            }
        }
        .padding(12)
    }
}
