//
//  FeedItemView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
import URLImage

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
                
                if item.image != nil && item.feed != nil && item.feed?.subscription?.showThumbnails == true {
                    thumbnailImage
                }
            }
        }
        .buttonStyle(ItemLinkButtonStyle(read: item.read))
        .frame(maxWidth: .infinity)
        .padding(12)
    }
    
    var thumbnailImage: some View {
        URLImage(
            url: item.image!,
            options: URLImageOptions(
                cachePolicy: URLImageOptions.CachePolicy.returnCacheDontLoad(delay: Double.random(in: 0.1 ..< 0.2))
            ),
            inProgress: { _ in
                VStack {
                    Image(systemName: "photo").foregroundColor(.secondary)
                }
                .frame(width: 96, height: 64)
                .background(Color(UIColor.secondarySystemBackground))
                .padding(1)
                .border(Color(UIColor.separator), width: 1)
            },
            failure: { _,_ in
                VStack {
                    Image(systemName: "exclamationmark.triangle").foregroundColor(.secondary)
                }
                .frame(width: 96, height: 64)
                .background(Color(UIColor.secondarySystemBackground))
                .padding(1)
                .border(Color(UIColor.separator), width: 1)
            },
            content: {
                $0
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        )
        .frame(width: 96, height: 64)
        .clipped()
        .padding(1)
        .border(Color(UIColor.separator), width: 1)
        .accessibility(label: Text("Thumbnail image"))
    }
    func openLink() {
        guard let url = item.link else { return }
        
        browserManager.logVisit(item: item)
        
        
        browserManager.openSafari(url: url)
    }
}
