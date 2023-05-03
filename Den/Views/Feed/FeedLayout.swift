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

    let items: [Item]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    if let heroImage = feed.feedData?.banner {
                        Divider()
                        FeedHero(heroImage: heroImage)
                        Divider()
                    }
                    if feed.feedData == nil || feed.feedData?.error != nil {
                        FeedUnavailable(feedData: feed.feedData, splashNote: true)
                    } else {
                        latestSection(geometry: geometry)
                        moreSection(geometry: geometry)
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
            if items.previews().isEmpty && hideRead == true {
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
                    ItemActionView(item: item, profile: profile) {
                        if feed.wrappedPreviewStyle == .expanded {
                            ItemExpanded(item: item)
                        } else {
                            ItemCompressed(item: item)
                        }
                    }
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
            if items.extras().isEmpty {
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
                    ItemActionView(item: item, profile: profile) {
                        if feed.wrappedPreviewStyle == .expanded {
                            ItemExpanded(item: item)
                        } else {
                            ItemCompressed(item: item)
                        }
                    }
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
                    HStack {
                        Button {
                            openURL(url)
                        } label: {
                            Label("\(feedURLString)", systemImage: "dot.radiowaves.up.forward").lineLimit(1)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("feed-url-button")

                        Button {
                            UIPasteboard.general.url = url
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("copy-feed-url-button")
                    }
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
