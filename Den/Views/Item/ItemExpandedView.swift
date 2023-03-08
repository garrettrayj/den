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

    var hasTeaser: Bool {
        item.teaser != nil && item.teaser != ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.wrappedTitle)
                    .modifier(CustomFontModifier(relativeTo: .headline, textStyle: .headline))
                    .fontWeight(.semibold)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
                ItemDateAuthorView(item: item)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .multilineTextAlignment(.leading)

            if item.feedData?.feed?.showThumbnails == true && item.image != nil {
                PreviewImageView(item: item)
                    .overlay(
                        .background.opacity(item.read ? 0.5 : 0)
                    )
            }

            if hasTeaser {
                Text(item.teaser!)
                    .modifier(CustomFontModifier(relativeTo: .body, textStyle: .body))
                    .lineLimit(6)
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding([.horizontal, .bottom], 12)
        .padding(.top, 8)
        
        .foregroundColor(
            isEnabled ?
                item.read ? .secondary : .primary
            :
                item.read ? Color(UIColor.quaternaryLabel) : Color(UIColor.tertiaryLabel)
        )
    }
}
