//
//  ItemPreviewCompressed.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemPreviewCompressed: View {
    @Bindable var item: Item
    @Bindable var feed: Feed

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                PreviewHeadline(title: item.titleText)
                if feed.showBylines, let author = item.author {
                    PreviewAuthor(author: author)
                }
                
                ItemPreviewMeta(item: item)
            }
            
            Spacer(minLength: 0)

            if feed.showImages, let url = item.image {
                SmallThumbnail(url: url, isRead: item.wrappedRead).padding(.leading, 12)
            }
        }
        .padding(12)
    }
}
