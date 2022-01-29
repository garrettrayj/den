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

    @ObservedObject var item: Item

    var feed: Feed

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Button {
                    linkManager.openLink(url: item.link, logHistoryItem: item, readerMode: feed.readerMode)
                } label: {
                    Text(item.wrappedTitle)
                }
                .buttonStyle(ItemButtonStyle(read: item.read))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .topLeading)

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
        .padding(.vertical, 12)
        .padding(.horizontal)
    }

    private var thumbnailImage: some View {
        item.thumbnailImage?
            .frame(width: ImageSize.thumbnail.width, height: ImageSize.thumbnail.height)
            .clipped()
            .background(Color(UIColor.tertiarySystemGroupedBackground))
                .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4).stroke(Color(UIColor.opaqueSeparator), lineWidth: 1)
            )
            .accessibility(label: Text("Thumbnail Image"))
            .padding(.top, 4)
    }
}
