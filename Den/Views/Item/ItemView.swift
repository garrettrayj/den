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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.useInbuiltBrowser) private var useInbuiltBrowser
    @Environment(\.openURL) private var openURL

    @ObservedObject var item: Item
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    var maxContentWidth: CGFloat {
        CGFloat(700) * dynamicTypeSize.layoutScalingFactor
    }

    var body: some View {
        if item.managedObjectContext == nil {
            SplashNote(title: "Item Deleted", symbol: "slash.circle")
        } else {
            itemLayout
                #if targetEnvironment(macCatalyst)
                .background(.thinMaterial.opacity(colorScheme == .dark ? 1 : 0), ignoresSafeAreaEdges: .all)
                .background(.background, ignoresSafeAreaEdges: .all)
                #else
                .background(.background, ignoresSafeAreaEdges: .all)
                #endif
                .toolbar {
                    if let link = item.link {
                        ToolbarItem(placement: .primaryAction) {
                            ShareLink(item: link).buttonStyle(ToolbarButtonStyle())
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            if let url = item.link {
                                if useInbuiltBrowser {
                                    SafariUtility.openLink(
                                        url: url,
                                        controlTintColor: profile.tintUIColor ?? .tintColor,
                                        readerMode: feed.readerMode
                                    )
                                } else {
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
        }
    }

    private var itemLayout: some View {
        GeometryReader { _ in
            ScrollView(.vertical) {
                VStack {
                    VStack(alignment: .leading, spacing: 16) {
                        FeedTitleLabel(
                            title: item.feedTitle,
                            favicon: item.feedData?.favicon
                        )
                        .font(.title3)
                        .textSelection(.enabled)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.wrappedTitle)
                                .font(.largeTitle)
                                .textSelection(.enabled)
                                .fixedSize(horizontal: false, vertical: true)

                            if let author = item.author {
                                Text(author).font(.subheadline).lineLimit(2)
                            }

                            TimelineView(.everyMinute) { _ in
                                Text("\(item.date.formatted(date: .complete, time: .shortened)) ") +
                                Text("(\(item.date.formatted(.relative(presentation: .numeric))))")
                            }
                            .font(.caption2)
                        }

                        if
                            item.image != nil &&
                            !(item.summary?.contains("<img") ?? false) &&
                            !(item.body?.contains("<img") ?? false)
                        {
                            ItemHero(item: item)
                        }

                        if item.body != nil || item.summary != nil {
                            ItemWebView(
                                html: item.body ?? item.summary!,
                                title: item.wrappedTitle,
                                baseURL: item.link,
                                tint: profile.tintUIColor
                            )
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: maxContentWidth)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .padding(.vertical, 8)
                .navigationBarTitleDisplayMode(.inline)
                .task { await HistoryUtility.markItemRead(item: item) }
            }
        }
    }
}
