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
    var feedData: FeedData {
        items.first!.feedData!
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                if feedData.faviconImage != nil {
                    feedData.faviconImage!.resizable().scaledToFit().frame(width: 16, height: 16)
                }
                Text(feedData.feed?.wrappedTitle ?? "Untitled").font(.headline).lineLimit(1)
                Spacer()
            }.padding(.horizontal, 12).padding(.vertical, 8)

            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        Group {
                            Divider()
                            FeedWidgetRowView(item: item, feed: feedData.feed!)
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
