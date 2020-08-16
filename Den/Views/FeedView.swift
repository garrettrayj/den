//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
import URLImage

/**
 Block view with channel title and items (articles)
 */
struct FeedView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var feed: Feed
    var parent: PageView
    
    func showOptions() {
        self.parent.editingFeed = self.feed
        self.parent.activeSheet = .feedEdit
        self.parent.showingSheet = true
    }
    
    func closeOptions() {
        self.parent.editingFeed = self.feed
        self.parent.activeSheet = .feedEdit
        self.parent.showingSheet = true
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                if feed.favicon != nil {
                    URLImage(
                        feed.favicon!,
                        processors: [ Resize(size: CGSize(width: 16, height: 16), scale: UIScreen.main.scale) ],
                        placeholder: { _ in
                            Image("RSSIcon").faviconView()
                        },
                        content: {
                            $0.image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        }
                    ).frame(width: 16, height: 16)
                }
                Text(feed.wrappedTitle).font(.headline).lineLimit(1)
                Spacer()
                Button(action: showOptions) {
                    Image(systemName: "ellipsis").resizable().scaledToFit().frame(width: 16, height: 16)
                }
            }.padding(.horizontal, 12).padding(.vertical, 8)
            Divider()
            VStack(spacing: 0) {
                if feed.itemsArray.count > 0 {
                    ForEach(feed.itemsArray.prefix(Int(feed.itemLimit))) { item in
                        Group {
                            FeedItemView(item: item)
                            Divider()
                        }
                    }
                } else {
                    if feed.refreshed == nil {
                        Text("Refresh to fetch items").modifier(FeedMessageModifier())
                    } else {
                        Text("Feed has no items").modifier(FeedMessageModifier())
                    }
                    
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}
