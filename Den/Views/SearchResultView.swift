//
//  SearchResultView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SearchResultView: View {
    var items: [Item]
    var feed: Feed {
        items.first!.feed!
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                if feed.faviconImage != nil {
                    feed.faviconImage!.resizable().scaledToFit().frame(width: 16, height: 16)
                }
                Text(feed.subscription?.wrappedTitle ?? "Untitled").font(.headline).lineLimit(1)
                Spacer()
            }.padding(.horizontal, 12).padding(.vertical, 8)

            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        Group {
                            Divider()
                            FeedWidgetItemRowView(item: item, subscription: feed.subscription!)
                        }
                    }
                }
                .drawingGroup()
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}
