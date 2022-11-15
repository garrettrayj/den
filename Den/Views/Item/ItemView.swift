//
//  ItemView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemView: View {
    @Environment(\.persistentContainer) private var container
    
    @ObservedObject var item: Item

    let maxContentWidth: CGFloat = 800

    var body: some View {
        if item.managedObjectContext == nil {
            StatusBoxView(message: Text("Item Deleted"), symbol: "slash.circle")
        } else {
            ScrollView(.vertical) {
                VStack {
                    VStack(alignment: .leading, spacing: 16) {
                        FeedTitleLabelView(
                            title: item.feedTitle,
                            favicon: item.feedData?.favicon
                        )
                        .font(.title3)
                        .textSelection(.enabled)

                        Text(item.wrappedTitle)
                            .font(.title)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)

                        
                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: 4) {
                                Text(item.date.formatted())
                                if let author = item.author {
                                    Text("•")
                                    Text(author)
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                Text(item.date.formatted())
                                if let author = item.author {
                                    Text(author)
                                }
                            }
                        }
                        .font(.subheadline)
                        .textSelection(.enabled)
                        
                        if
                            item.image != nil &&
                            !(item.summary?.contains("<img") ?? false) &&
                            !(item.body?.contains("<img") ?? false)
                        {
                            HeroImageView(item: item)
                        }

                        if item.body != nil || item.summary != nil {
                            WebView(
                                html: item.body ?? item.summary!,
                                title: item.wrappedTitle,
                                baseURL: item.link
                            ).frame(maxWidth: .infinity)
                        }
                    }
                    .padding(28)
                    .frame(maxWidth: maxContentWidth)
                }
                .frame(maxWidth: .infinity)
            }
            .toolbar {
                if let link = item.link {
                    ToolbarItem {
                        ShareLink(item: link).buttonStyle(ToolbarButtonStyle())
                    }
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button {
                        SafariUtility.openLink(url: item.link)
                    } label: {
                        #if targetEnvironment(macCatalyst)
                        Label("Open in Browser", systemImage: "link.circle")
                        #else
                        Label("Open in Browser", systemImage: "safari")
                        #endif
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .accessibilityIdentifier("item-open-button")
                }
            }
            .task(priority: TaskPriority.userInitiated) {
                await SyncUtility.markItemRead(container: container, item: item)
            }
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
