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

    @Binding var hideRead: Bool

    @State var urlCopied: Bool = false

    let items: FetchedResults<Item>

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
                        latestSection(geometry: geometry)

                        if !items.extras().isEmpty {
                            moreSection(geometry: geometry)
                        }
                    }
                    Divider()
                    metaSection.modifier(SafeAreaModifier(geometry: geometry))
                }
            }
            .edgesIgnoringSafeArea(.horizontal)
        }
    }

    private func latestSection(geometry: GeometryProxy) -> some View {
        Section {
            if items.visibilityFiltered(hideRead ? false : nil).previews().isEmpty && hideRead == true {
                AllRead()
                    .padding(12)
                    .background(QuaternaryGroupedBackground())
                    .modifier(RoundedContainerModifier())
                    .padding()
                    .modifier(SafeAreaModifier(geometry: geometry))
            } else {
                BoardView(
                    geometry: geometry,
                    list: items.previews(),
                    isLazy: false
                ) { item in
                    ItemActionView(item: item, feed: feed, profile: profile) {
                        if feed.wrappedPreviewStyle == .expanded {
                            ItemExpanded(item: item, feed: feed)
                        } else {
                            ItemCompressed(item: item, feed: feed)
                        }
                    }
                    .background(SecondaryGroupedBackground())
                    .modifier(RoundedContainerModifier())
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
    }

    private func moreSection(geometry: GeometryProxy) -> some View {
        Section {
            if items.visibilityFiltered(hideRead ? false : nil).extras().isEmpty {
                AllRead()
                    .padding(12)
                    .background(QuaternaryGroupedBackground())
                    .modifier(RoundedContainerModifier())
                    .padding()
                    .modifier(SafeAreaModifier(geometry: geometry))
            } else {
                BoardView(
                    geometry: geometry,
                    list: items.extras(),
                    isLazy: false
                ) { item in
                    ItemActionView(item: item, feed: feed, profile: profile) {
                        if feed.wrappedPreviewStyle == .expanded {
                            ItemExpanded(item: item, feed: feed)
                        } else {
                            ItemCompressed(item: item, feed: feed)
                        }
                    }
                    .background(SecondaryGroupedBackground())
                    .modifier(RoundedContainerModifier())
                }
                .padding(.vertical)
                .modifier(SafeAreaModifier(geometry: geometry))
            }
        } header: {
            Text("More")
                .font(.title2)
                .modifier(SafeAreaModifier(geometry: geometry))
                .modifier(PinnedSectionHeaderModifier())
        }
    }

    private var metaSection: some View {
        Section {
            VStack(alignment: .center, spacing: 12) {
                if let description = feed.feedData?.metaDescription {
                    Text(description).frame(maxWidth: 640)
                }

                if let linkDisplayString = feed.feedData?.linkDisplayString, let url = feed.feedData?.link {
                    Button {
                        openURL(url)
                    } label: {
                        Text(linkDisplayString).lineLimit(1)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("feed-link-button")
                }

                if let feedURLString = feed.url?.absoluteString, let url = feed.url {
                    Button {
                        UIPasteboard.general.url = url
                        urlCopied = true
                    } label: {
                        Text(feedURLString).lineLimit(1)
                        Label("Copy", systemImage: "doc.on.doc").labelStyle(.iconOnly)
                        if urlCopied {
                            Text("Copied").foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("copy-feed-url-button")
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
