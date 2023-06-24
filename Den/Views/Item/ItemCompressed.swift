//
//  ItemCompressed.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemCompressed: View {
    @ObservedObject var item: Item
    @ObservedObject var feed: Feed

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.wrappedTitle)
                    .font(.headline)
                    .lineLimit(6)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                if feed.hideBylines == false, let author = item.author {
                    Text(author).font(.subheadline).lineLimit(2)
                }

                PublishedDateActionLine(
                    date: item.date,
                    browserView: feed.browserView
                ).font(.caption2)
            }

            if feed.hideImages != true, let url = item.image {
                Spacer()
                ItemThumbnailImage(
                    url: url,
                    isRead: item.read,
                    aspectRatio: item.imageAspectRatio
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(12)
        .fixedSize(horizontal: false, vertical: true)
    }
}
