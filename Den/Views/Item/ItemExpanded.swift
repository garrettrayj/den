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
        item.teaser != nil && item.teaser != "" && item.feedData?.feed?.hideTeasers != true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.wrappedTitle)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(6)
                .fixedSize(horizontal: false, vertical: true)

            ItemDateAuthor(item: item)

            if item.feedData?.feed?.hideImages != true && item.image != nil {
                ItemPreviewImage(item: item)
                    .padding(.top, 4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if showTeaser {
                Text(item.teaser!)
                    #if !targetEnvironment(macCatalyst)
                    .font(.caption)
                    #endif
                    .lineLimit(6)
                    .padding(.top, 4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(12)
    }
}
