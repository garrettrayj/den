//
//  ExpandedItemPreview.swift
//  Den
//
//  Created by Garrett Johnson on 12/10/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ExpandedItemPreview: View {
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var item: Item
    @ObservedObject var feed: Feed

    var showTeaser: Bool {
        item.teaser != nil && item.teaser != "" && feed.hideTeasers != true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            PreviewHeadline(title: item.wrappedTitle)

            if feed.hideBylines == false, let author = item.author {
                Text(author)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)
                    .foregroundStyle(isEnabled ? .secondary : .tertiary)
            }

            VStack(alignment: .leading, spacing: 4) {
                PreviewDateAndAction(date: item.date, browserView: feed.browserView)
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

            if showTeaser {
                PreviewTeaser(teaser: item.teaser!)
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
    }
}
