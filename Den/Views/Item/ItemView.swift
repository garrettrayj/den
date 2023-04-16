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
        CGFloat(740) * dynamicTypeSize.layoutScalingFactor
    }

    var body: some View {
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
                .navigationBarTitleDisplayMode(.inline)
                .task { await HistoryUtility.markItemRead(item: item) }
            }
            .background(.background)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: item.link!)
                    .modifier(ToolbarButtonModifier())
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Text("")
                Spacer()
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
                .modifier(ToolbarButtonModifier())
                .accessibilityIdentifier("item-open-button")
            }
        }
    }
}
