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
    @ObservedObject var feed: Feed
    
    var parent: PageView
    
    func showOptions() {
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
                        //processors: [ Resize(size: CGSize(width: 16, height: 16), scale: UIScreen.main.scale) ],
                        placeholder: { _ in
                            Image("RSSIcon").faviconView()
                        },
                        failure: { _ in
                            Image("RSSIcon").faviconView()
                        },
                        content: {
                            $0.image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 16, height: 16)
                                .clipped()
                            
                        }
                    )
                    .frame(width: 16, height: 16)
                    .clipped()
                    .accessibility(label: Text("Favicon"))
                }
                Text(feed.wrappedTitle).font(.headline).lineLimit(1)
                Spacer()
                Button(action: showOptions) {
                    Image(systemName: "ellipsis").faviconView()
                }
            }.padding(.horizontal, 12).padding(.vertical, 8)

            VStack(spacing: 0) {
                if feed.error != nil {
                    Divider()
                    VStack {
                        VStack(spacing: 4) {
                            Text("Unable to update feed:")
                                .foregroundColor(.secondary)
                                .font(.callout)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(feed.error!)
                                .foregroundColor(.red)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    .background(RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1).foregroundColor(.red))
                    .padding([.horizontal, .top])
                    .padding(.bottom, 2)
                    .frame(maxWidth: .infinity)
                }
                
                if feed.itemsArray.count > 0 {
                    VStack(spacing: 0) {
                        ForEach(feed.itemsArray.prefix(Int(feed.itemLimit))) { item in
                            Group {
                                Divider()
                                FeedItemView(item: item)
                            }
                        }
                    }
                    .drawingGroup()
                } else {
                    if feed.refreshed == nil {
                        Text("Feed Never Fetched")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Feed Empty")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}
