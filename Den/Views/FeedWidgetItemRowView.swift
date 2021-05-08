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
    @EnvironmentObject var browserManager: BrowserManager
    @ObservedObject var item: Item
    @ObservedObject var subscription: Subscription
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if item.published != nil {
                Text("\(item.published!, formatter: DateFormatter.create())")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }
            
            HStack(alignment: .top, spacing: 10) {
                Button(action: openLink) {
                    Text(item.wrappedTitle)
                }
                
                if item.thumbnailImage != nil && item.feed != nil && item.feed?.subscription?.showThumbnails == true {
                    thumbnailImage
                }
            }
        }
        .buttonStyle(ItemLinkButtonStyle(read: item.read))
        .frame(maxWidth: .infinity)
        .padding(12)
    }
    
    var thumbnailImage: some View {
        item.thumbnailImage?
        .scaleEffect(1 / UIScreen.main.scale)
        .frame(width: 96, height: 64, alignment: .center)
        .clipped()
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .padding(1)
        .border(Color(UIColor.separator), width: 1)
        .accessibility(label: Text("Thumbnail Image"))
    }
    
    func openLink() {
        guard let url = item.link else { return }
        
        browserManager.logVisit(item: item)
        browserManager.openSafari(url: url)
        
        // Update unread count in page navigation
        item.feed?.subscription?.page?.objectWillChange.send()
    }
}
