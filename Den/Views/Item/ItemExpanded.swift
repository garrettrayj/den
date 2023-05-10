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

            ItemDateAuthor(item: item, feed: feed)

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
    }
}
