//
//  ItemView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemView: View {
    @Environment(\.useInbuiltBrowser) private var useInbuiltBrowser
    @Environment(\.openURL) private var openURL

    let item: Item
    let maxContentWidth: CGFloat = 800

    var body: some View {
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
                .padding(.horizontal, 24)
                .padding(.vertical)
                .frame(maxWidth: maxContentWidth)
            }
            .frame(maxWidth: .infinity)
        }
        .toolbar {
            ToolbarItem {
                ShareLink(item: item.link!).buttonStyle(ToolbarButtonStyle())
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Button {
                    if useInbuiltBrowser {
                        SafariUtility.openLink(
                            url: item.link,
                            readerMode: item.feedData?.feed?.readerMode ?? false
                        )
                    } else {
                        if let url = item.link {
                            openURL(url)
                        }
                    }
                } label: {
                    Label("Open in Browser", systemImage: "link.circle")
                }
                .buttonStyle(PlainToolbarButtonStyle())
                .accessibilityIdentifier("item-open-button")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await HistoryUtility.markItemRead(item: item)
        }
    }
}
