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
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var item: Item
    @ObservedObject var feed: Feed

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                PreviewHeadline(title: item.wrappedTitle, browserView: feed.browserView)
                if feed.hideBylines == false, let author = item.author {
                    PreviewAuthor(author: author)
                }
                PreviewDateline(date: item.published)
                if !item.bookmarks.isEmpty {
                    ItemTags(item: item)
                }
            }
            Spacer()
            if feed.hideImages != true, let url = item.image {
                PreviewThumbnail(url: url, isRead: item.read)
            }
        }
        .padding()
    }
}
