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
                }.accessibility(identifier: "Item Link")

                if item.feedData?.feed?.showThumbnails == true {
                    thumbnailImage
                }
            }
        }
        .buttonStyle(ItemLinkButtonStyle(read: item.read))
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
        guard let url = item.link else { return }
        linkManager.openLink(url: url, logHistoryItem: item, readerMode: feed.readerMode)
    }
}
