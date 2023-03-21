//
//  FeedLayoutView.swift
//  Den
//
//  Created by Garrett Johnson on 3/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedLayoutView: View {
    @Environment(\.openURL) private var openURL

    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    let hideRead: Bool
    let previewStyle: PreviewStyle

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    if let heroImage = feed.feedData?.banner {
                        FeedHeroView(heroImage: heroImage)
                        Divider()
                    }

                    WithItems(
                        scopeObject: feed,
                        readFilter: hideRead ? false : nil,
                        includeExtras: true
                    ) { items in
                        Section {
                            if feed.feedData == nil || feed.feedData?.error != nil {
                                FeedUnavailableView(feedData: feed.feedData, splashNote: true)
                            } else if items.isEmpty {
                                AllReadStatusView()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .modifier(RaisedGroupModifier())
                                    .modifier(SectionContentPaddingModifier())
                            } else {
                                BoardView(
                                    width: geometry.size.width,
                                    list: Array(items).previews()
                                ) { item in
                                    ItemActionView(item: item) {
                                        if previewStyle == .compressed {
                                            ItemCompressedView(item: item)
                                        } else {
                                            ItemExpandedView(item: item)
                                        }
                                    }
                                    .modifier(RaisedGroupModifier())
                                }.modifier(SectionContentPaddingModifier())
                            }
                        } header: {
                            Text("Latest").font(.title3).modifier(PinnedSectionHeaderModifier())
                        }

                        if items.count > feed.wrappedItemLimit && (
                            feed.feedData != nil && feed.feedData?.error == nil
                        ) {
                            Section {
                                if items.isEmpty {
                                    AllReadStatusView()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .modifier(RaisedGroupModifier())
                                        .modifier(SectionContentPaddingModifier())
                                } else {
                                    BoardView(
                                        width: geometry.size.width,
                                        list: Array(items).extras()
                                    ) { item in
                                        ItemActionView(item: item) {
                                            if previewStyle == .compressed {
                                                ItemCompressedView(item: item)
                                            } else {
                                                ItemExpandedView(item: item)
                                            }
                                        }
                                        .modifier(RaisedGroupModifier())
                                    }.modifier(SectionContentPaddingModifier())
                                }
                            } header: {
                                Text("More").font(.title3).modifier(PinnedSectionHeaderModifier())
                            }
                        }
                    }
                    Divider()
                    metaSection
                }
            }
        }
    }

    private var metaSection: some View {
        Section {
            VStack(alignment: .center, spacing: 12) {
                if let description = feed.feedData?.metaDescription {
                    Text(description)
                }

                if let linkDisplayString = feed.feedData?.linkDisplayString {
                    Button {
                        if let url = feed.feedData?.link {
                            openURL(url)
                        }
                    } label: {
                        Label("\(linkDisplayString)", systemImage: "globe").lineLimit(1)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    openURL(feed.url!)
                } label: {
                    Label("\(feed.urlString)", systemImage: "dot.radiowaves.up.forward").lineLimit(1)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("feed-copy-url-button")

                if let copyright = feed.feedData?.copyright {
                    Text(copyright)
                }
            }
            .font(.footnote)
            .imageScale(.small)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
    }
}
