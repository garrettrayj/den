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

            PublishedDateActionLine(item: item, feed: feed).font(.caption2)

            if feed.hideImages != true && item.image != nil {
                ItemPreviewImage(item: item).padding(.top, 4)
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
        .padding(12)
        .fixedSize(horizontal: false, vertical: true)
    }
}
