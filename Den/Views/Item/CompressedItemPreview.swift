//
//  CompressedItemPreview.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct CompressedItemPreview: View {
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var item: Item
    @ObservedObject var feed: Feed

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                PreviewHeadline(title: item.wrappedTitle)

                if feed.hideBylines == false, let author = item.author {
                    Text(author)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(2)
                        .foregroundStyle(isEnabled ? .secondary : .tertiary)
                }

                VStack(alignment: .leading) {
                    PreviewDateAndAction(date: item.date, browserView: feed.browserView)
                    if !item.bookmarks.isEmpty {
                        ItemTags(item: item)
                    }
                }
            }

            if feed.hideImages != true, let url = item.image {
                Spacer()
                PreviewThumbnail(url: url, isRead: item.read)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
    }
}
