//
//  ItemPreviewExpanded.swift
//  Den
//
//  Created by Garrett Johnson on 12/10/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemPreviewExpanded: View {
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var item: Item
    @ObservedObject var feed: Feed

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            PreviewHeadline(title: item.wrappedTitle, browserView: feed.browserView)
            if feed.hideBylines == false, let author = item.author {
                PreviewAuthor(author: author)
            }
            VStack(alignment: .leading, spacing: 4) {
                PreviewDateline(date: item.published)
                if !item.bookmarks.isEmpty {
                    ItemTags(item: item)
                }
            }
            if feed.hideImages != true, let url = item.image {
                PreviewImage(
                    url: url,
                    isRead: item.read,
                    width: CGFloat(item.imageWidth),
                    height: CGFloat(item.imageHeight)
                ).padding(.top, 4)
            }
            if let teaser = item.teaser, teaser != "" && !feed.hideTeasers {
                PreviewTeaser(teaser: teaser)
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
    }
}
