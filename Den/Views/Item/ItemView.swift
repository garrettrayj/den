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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.useInbuiltBrowser) private var useInbuiltBrowser
    @Environment(\.openURL) private var openURL

    @ObservedObject var item: Item
    @ObservedObject var profile: Profile

    var maxContentWidth: CGFloat {
        return CGFloat(700) * dynamicTypeSize.layoutScalingFactor
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    FeedTitleLabel(
                        title: item.feedTitle,
                        favicon: item.feedData?.favicon
                    )
                    .font(.title3)
                    .textSelection(.enabled)

                    Group {
                        Text(item.wrappedTitle)
                            .font(.largeTitle)
                            .textSelection(.enabled)
                            .padding(.top, 8)
                            .fixedSize(horizontal: false, vertical: true)

                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: 4) {
                                Text(item.date.formatted(date: .long, time: .shortened))
                                if let author = item.author {
                                    Text("•")
                                    Text(author)
                                }
                            }
                            VStack(alignment: .leading) {
                                Text(item.date.formatted(date: .long, time: .shortened))
                                if let author = item.author {
                                    Text(author)
                                }
                            }
                        }
                        .font(.subheadline)

                        if
                            item.image != nil &&
                            !(item.summary?.contains("<img") ?? false) &&
                            !(item.body?.contains("<img") ?? false)
                        {
                            ItemHero(item: item).padding(.top, 8)
                        }

                        if item.body != nil || item.summary != nil {
                            ItemWebView(
                                html: item.body ?? item.summary!,
                                title: item.wrappedTitle,
                                baseURL: item.link,
                                tint: profile.tintUIColor
                            ).padding(.top, 8)
                        }
                    }
                    .multilineTextAlignment(.leading)
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 28)
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
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await HistoryUtility.markItemRead(item: item)
        }
    }
}
