//
//  ItemCompressedView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemCompressedView: View {
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var item: Item

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.wrappedTitle)
                    .modifier(CustomFontModifier(relativeTo: .headline, textStyle: .headline))
                    .fontWeight(.semibold)
                    .lineLimit(3)

                ItemDateAuthorCompressedView(item: item)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .multilineTextAlignment(.leading)

            if item.feedData?.feed?.showThumbnails == true {
                ThumbnailView(item: item).opacity(item.read ? AppDefaults.dimmedImageOpacity : 1.0)
            }
        }
        .padding(8)
    }
}
