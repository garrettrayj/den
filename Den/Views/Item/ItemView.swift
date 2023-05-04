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
                    ToolbarItem(placement: .primaryAction) {
                        if let link = item.link {
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
                                        readerMode: item.feedData?.feed?.readerMode ?? false
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

                        Text(item.wrappedTitle)
                            .font(.largeTitle)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)

                        ItemDateAuthor(item: item, dateStyle: .long, timeStyle: .shortened)

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
