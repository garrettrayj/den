//
//  ItemExpandedView.swift
//  Den
//
//  Created by Garrett Johnson on 12/10/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemExpandedView: View {
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var item: Item

    var showFavicon: Bool = false

    var hasTeaser: Bool {
        item.teaser != nil && item.teaser != ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.wrappedTitle)
                .modifier(CustomFontModifier(relativeTo: .headline, textStyle: .headline))
                .fontWeight(.semibold)
                .lineLimit(6)

            ItemDateAuthorView(item: item)

            if item.feedData?.feed?.showThumbnails == true && item.image != nil {
                PreviewImageView(item: item)
                    .overlay(.background.opacity(item.read ? 0.5 : 0))
                    .padding(.top, 4)
            }

            if hasTeaser {
                Text(item.teaser!)
                    .modifier(CustomFontModifier(relativeTo: .body, textStyle: .body))
                    .lineLimit(6)
                    .padding(.top, 4)
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(12)
        .foregroundColor(
            isEnabled ?
                item.read ? Color(.secondaryLabel) : Color(.label)
            :
                item.read ? Color(.quaternaryLabel) : Color(.tertiaryLabel)
        )
        .fixedSize(horizontal: false, vertical: true)
    }
}
