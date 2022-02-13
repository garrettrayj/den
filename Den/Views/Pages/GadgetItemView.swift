//
//  GadgetItemView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

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
                        Text("\(item.published!, formatter: DateFormatter.mediumShort)")
                            .font(.caption)
                            .foregroundColor(Color(.secondaryLabel))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .multilineTextAlignment(.leading)

                if feed.showThumbnails == true {
                    item.thumbnailImage?
                        .frame(width: ImageSize.thumbnail.width, height: ImageSize.thumbnail.height)
                        .clipped()
                        .background(Color(UIColor.tertiarySystemGroupedBackground))
                            .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4).stroke(Color(UIColor.opaqueSeparator), lineWidth: 1)
                        )
                        .accessibility(label: Text("Thumbnail Image"))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
        }
        .buttonStyle(ItemButtonStyle(read: item.read))
        .accessibilityIdentifier("gadget-item-button")
    }
}
