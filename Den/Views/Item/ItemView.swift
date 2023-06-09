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
    @Environment(\.useSystemBrowser) private var useSystemBrowser
    @Environment(\.openURL) private var openURL

    @ObservedObject var item: Item
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    var maxContentWidth: CGFloat {
        CGFloat(700) * dynamicTypeSize.layoutScalingFactor
    }

    var body: some View {
        if item.managedObjectContext == nil {
            SplashNote(title: Text("Item Deleted", comment: "Object removed message."), symbol: "slash.circle")
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
                            ShareLink(item: link) {
                                Label {
                                    Text("Share…", comment: "Toolbar button label.")
                                } icon: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                            .buttonStyle(ToolbarButtonStyle())
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            if let url = item.link {
                                if useSystemBrowser {
                                    openURL(url)
                                } else {
                                    SafariUtility.openLink(
                                        url: url,
                                        controlTintColor: profile.tintUIColor ?? .tintColor,
                                        readerMode: feed.readerMode
                                    )
                                }
                            }
                        } label: {
                            Label {
                                Text("Open in Browser", comment: "Toolbar button label.")
                            } icon: {
                                Image(systemName: "link.circle")
                            }
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
                            title: item.feedData?.feed?.titleText,
                            favicon: item.feedData?.favicon
                        )
                        .font(.title3)
                        .textSelection(.enabled)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.wrappedTitle)
                                .font(.largeTitle)
                                .textSelection(.enabled)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 4)

                            if let author = item.author {
                                Text(author).font(.subheadline).lineLimit(2)
                            }

                            TimelineView(.everyMinute) { _ in
                                HStack {
                                    Text(verbatim: item.date.formatted(date: .complete, time: .shortened))
                                    Text(verbatim: "(\(item.date.formatted(.relative(presentation: .numeric))))")
                                }.font(.caption2)
                            }
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
