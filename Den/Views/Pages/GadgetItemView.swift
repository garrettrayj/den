//
//  GadgetItemView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
import Kingfisher

struct GadgetItemView: View {
    @EnvironmentObject private var linkManager: LinkManager

    @ObservedObject var item: Item
    @ObservedObject var feed: Feed

    var body: some View {
        Button {
            linkManager.openLink(url: item.link, logHistoryItem: item, readerMode: feed.readerMode)
        } label: {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.wrappedTitle).lineLimit(10)

                    if item.published != nil {
                        ItemDateView(date: item.published!, read: item.read)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .multilineTextAlignment(.leading)

                if feed.showThumbnails == true && item.image != nil {
                    KFImage(item.image)
                        .resizable()
                        .resizing(referenceSize: ImageReferenceSize.thumbnail, mode: .aspectFill)
                        .frame(width: ImageSize.thumbnail.width, height: ImageSize.thumbnail.height)
                        .clipped()
                        .background(Color(UIColor.tertiarySystemGroupedBackground))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4).stroke(Color(UIColor.opaqueSeparator), lineWidth: 1)
                        )
                        .accessibility(label: Text("Thumbnail Image"))
                        .opacity(item.read ? 0.65 : 1.0)
                }
            }
            .padding(12)
        }
        .buttonStyle(ItemButtonStyle(read: item.read))
        .accessibilityIdentifier("gadget-item-button")
    }
}
