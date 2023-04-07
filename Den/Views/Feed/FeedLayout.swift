//
//  FeedLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedLayout: View {
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
                        FeedHero(heroImage: heroImage)
                    }

                    if feed.feedData == nil || feed.feedData?.error != nil {
                        FeedUnavailable(feedData: feed.feedData, splashNote: true)
                    } else {
                        WithItems(
                            scopeObject: feed,
                            readFilter: hideRead ? false : nil,
                            includeExtras: true
                        ) { items in
                            Section {
                                if items.previews().isEmpty && hideRead == true {
                                    AllRead()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .modifier(RaisedGroupModifier())
                                        .padding()
                                        .modifier(SafeAreaModifier(geometry: geometry))
                                } else {
                                    BoardView(
                                        geometry: geometry,
                                        list: Array(items).previews()
                                    ) { item in
                                        ItemActionView(item: item) {
                                            if previewStyle == .compressed {
                                                ItemCompressed(item: item)
                                            } else {
                                                ItemExpanded(item: item)
                                            }
                                        }
                                        .modifier(RaisedGroupModifier())
                                    }
                                    .padding(.vertical)
                                    .modifier(SafeAreaModifier(geometry: geometry))
                                }
                            } header: {
                                Text("Latest")
                                    .font(.title3)
                                    .modifier(SafeAreaModifier(geometry: geometry))
                                    .modifier(PinnedSectionHeaderModifier())
                            }

                            Section {
                                if items.extras().isEmpty {
                                    AllRead()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .modifier(RaisedGroupModifier())
                                        .padding()
                                        .modifier(SafeAreaModifier(geometry: geometry))
                                } else {
                                    BoardView(
                                        geometry: geometry,
                                        list: Array(items).extras()
                                    ) { item in
                                        ItemActionView(item: item) {
                                            if previewStyle == .compressed {
                                                ItemCompressed(item: item)
                                            } else {
                                                ItemExpanded(item: item)
                                            }
                                        }
                                        .modifier(RaisedGroupModifier())
                                    }
                                    .padding(.vertical)
                                    .modifier(SafeAreaModifier(geometry: geometry))
                                }
                            } header: {
                                Text("More")
                                    .font(.title3)
                                    .modifier(SafeAreaModifier(geometry: geometry))
                                    .modifier(PinnedSectionHeaderModifier())
                            }
                        }
                    }
                    Divider()
                    metaSection.modifier(SafeAreaModifier(geometry: geometry))
                }
            }.edgesIgnoringSafeArea(.horizontal)
        }
    }

    private var metaSection: some View {
        Section {
            VStack(alignment: .center, spacing: 12) {
                if let description = feed.feedData?.metaDescription {
                    Text(description).frame(maxWidth: 640)
                }

                if let linkDisplayString = feed.feedData?.linkDisplayString {
                    Button {
                        if let url = feed.feedData?.link {
                            openURL(url)
                        }
                    } label: {
                        Label("\(linkDisplayString)", systemImage: "link").lineLimit(1)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("feed-link-button")
                }

                if let feedURLString = feed.url?.absoluteString {
                    Button {
                        if let url = feed.url {
                            openURL(url)
                        }
                    } label: {
                        Label("\(feedURLString)", systemImage: "dot.radiowaves.up.forward").lineLimit(1)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("feed-url-button")
                }

                if let copyright = feed.feedData?.copyright {
                    Text(copyright)
                }
            }
            .textSelection(.enabled)
            .font(.footnote)
            .imageScale(.small)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
    }
}
