//
//  GadgetItemView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetItemView: View {
    @EnvironmentObject var linkManager: LinkManager

    var item: Item
    var feed: Feed

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Button {
                    linkManager.openLink(url: item.link, logHistoryItem: item, readerMode: feed.readerMode)
                } label: {
                    Text(item.wrappedTitle)
                }
                .buttonStyle(ItemButtonStyle(read: item.read))
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .accessibility(identifier: "Item Link")

                if item.published != nil {
                    Text("\(item.published!, formatter: DateFormatter.mediumShort)")
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                }
            }

            if feed.showThumbnails == true {
                thumbnailImage
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var thumbnailImage: some View {
        item.thumbnailImage?
            .thumbnail()
            .background(Color(UIColor.tertiarySystemGroupedBackground))
                .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4).stroke(Color(UIColor.opaqueSeparator), lineWidth: 1)
            )
            .accessibility(label: Text("Thumbnail Image"))
    }
}
