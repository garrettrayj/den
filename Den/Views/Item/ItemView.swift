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
    
    let item: Item

    let maxContentWidth: CGFloat = 800

    var body: some View {
        Group {
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

                            Text("\(item.date.formatted(date: .complete, time: .shortened))")
                                .font(.subheadline)
                                .textSelection(.enabled)
                                .lineLimit(1)

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
                                )
                            }
                        }
                        .padding(28)
                        .frame(maxWidth: maxContentWidth)
                    }
                    .frame(maxWidth: .infinity)
                }
                .toolbar {
                    if let link = item.link {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            ShareLink(item: link).buttonStyle(ToolbarButtonStyle())
                        }
                    }

                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        Button {
                            SafariManager.openLink(url: item.link)
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
                .task(priority: TaskPriority.high) {
                    await SyncManager.markItemRead(container: container, item: item)
                }
            }
        }
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
    }
}
