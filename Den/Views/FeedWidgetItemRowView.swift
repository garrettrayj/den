//
//  FeedItemView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 Item (article) row for feeds
 */
struct FeedWidgetItemRowView: View {
    @EnvironmentObject var linkManager: LinkManager
    @ObservedObject var item: Item
    @ObservedObject var feed: Feed
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if item.published != nil {
                Text("\(item.published!, formatter: DateFormatter.create())")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }
            
            HStack(alignment: .top, spacing: 12) {
                Button(action: openLink) {
                    Text(item.wrappedTitle)
                }
                
                if item.thumbnailImage != nil && item.feedData != nil && item.feedData?.feed?.showThumbnails == true {
                    thumbnailImage
                }
            }
        }
        .buttonStyle(ItemLinkButtonStyle(read: item.read))
        .frame(maxWidth: .infinity)
        .padding(12)
    }
    
    private var thumbnailImage: some View {
        item.thumbnailImage?
        .scaleEffect(1 / UIScreen.main.scale)
        .frame(width: 96, height: 64, alignment: .center)
        .clipped()
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .accessibility(label: Text("Thumbnail Image"))
    }
    
    private func openLink() {
        guard let url = item.link else { return }
        linkManager.openLink(url: url, logHistoryItem: item, readerMode: feed.readerMode)
    }
}
