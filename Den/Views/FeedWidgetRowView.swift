//
//  FeedItemView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedWidgetRowView: View {
    @EnvironmentObject var linkManager: LinkManager

    @ObservedObject var item: Item
    @ObservedObject var feed: Feed

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if item.published != nil {
                Text("\(item.published!, formatter: DateFormatter.mediumShort)")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }

            HStack(alignment: .top, spacing: 8) {
                Button(action: openLink) {
                    Text(item.wrappedTitle)
                }
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .accessibility(identifier: "Item Link")

                if item.feedData?.feed?.showThumbnails == true {
                    thumbnailImage
                }
            }
        }
        .buttonStyle(ItemButtonStyle(read: item.read))
        .frame(minWidth: 200, maxWidth: .infinity)
        .padding(12)
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

    private func openLink() {
        linkManager.openLink(url: item.link, logHistoryItem: item, readerMode: feed.readerMode)
    }
}
