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

    var showTeaser: Bool {
        item.teaser != nil && item.teaser != ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.wrappedTitle)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(6)

            ItemDateAuthor(item: item)

            if item.feedData?.feed?.showThumbnails == true && item.image != nil {
                ItemPreviewImage(item: item)
                    .overlay(.background.opacity(item.read ? 0.5 : 0))
                    .padding(.top, 4)
            }

            if showTeaser {
                Text(item.teaser!).font(.body).lineLimit(6).padding(.top, 4)
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(12)
        .fixedSize(horizontal: false, vertical: true)
    }
}
