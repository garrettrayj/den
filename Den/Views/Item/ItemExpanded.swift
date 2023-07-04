//
//  ItemExpanded.swift
//  Den
//
//  Created by Garrett Johnson on 12/10/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemExpanded: View {
    @ObservedObject var item: Item
    @ObservedObject var feed: Feed

    var showTeaser: Bool {
        item.teaser != nil && item.teaser != "" && feed.hideTeasers != true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ItemTitle(item: item)

            if feed.hideBylines == false, let author = item.author {
                Text(author).font(.subheadline).lineLimit(2)
            }

            PublishedDateActionLine(
                date: item.date,
                browserView: feed.browserView
            ).font(.caption2)

            if feed.hideImages != true, let url = item.image {
                ItemPreviewImage(
                    url: url,
                    isRead: item.read,
                    aspectRatio: item.imageAspectRatio,
                    width: CGFloat(item.imageWidth),
                    height: CGFloat(item.imageHeight)
                ).padding(.top, 4)
            }

            if showTeaser {
                Text(item.teaser!)
                    .font(.callout)
                    .lineLimit(6)
                    .padding(.top, 4)
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        .fixedSize(horizontal: false, vertical: true)
    }
}
