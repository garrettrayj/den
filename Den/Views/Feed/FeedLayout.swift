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

    @State private var webpageCopied: Bool = false
    @State private var feedAddressCopied: Bool = false

    let items: FetchedResults<Item>

    private var filteredItems: [Item] {
        items.visibilityFiltered(hideRead ? false : nil)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    if let heroImage = feed.feedData?.banner {
                        FeedHero(heroImage: heroImage)
                    }

                    if feed.feedData == nil || feed.feedData?.error != nil {
                        FeedUnavailable(feedData: feed.feedData)
                            .padding(12)
                            .background(QuaternaryGroupedBackground())
                            .modifier(RoundedContainerModifier())
                            .padding()
                            .modifier(SafeAreaModifier(geometry: geometry))
                    }

                    if !items.previews().isEmpty {
                        latestSection(geometry: geometry)
                    }

                    if !items.extras().isEmpty {
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
            if filteredItems.previews().isEmpty && hideRead == true {
                AllRead()
                    .padding(12)
                    .background(QuaternaryGroupedBackground())
                    .modifier(RoundedContainerModifier())
                    .padding()
                    .modifier(SafeAreaModifier(geometry: geometry))
            } else {
                BoardView(
                    geometry: geometry,
                    list: filteredItems.previews(),
                    lazy: false
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
                .padding()
                .modifier(SafeAreaModifier(geometry: geometry))
            }
        } header: {
            Text("Latest", comment: "Feed view section header.")
                .font(.title3)
                .modifier(SafeAreaModifier(geometry: geometry))
                .modifier(PinnedSectionHeaderModifier())
        }
    }

    private func moreSection(geometry: GeometryProxy) -> some View {
        Section {
            if filteredItems.extras().isEmpty {
                AllRead()
                    .padding(12)
                    .background(QuaternaryGroupedBackground())
                    .modifier(RoundedContainerModifier())
                    .padding()
                    .modifier(SafeAreaModifier(geometry: geometry))
            } else {
                BoardView(
                    geometry: geometry,
                    list: filteredItems.extras(),
                    lazy: false
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
                .padding()
                .modifier(SafeAreaModifier(geometry: geometry))
            }
        } header: {
            Text("More", comment: "Feed view section header.")
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

                if
                    let linkDisplayString = feed.feedData?.link?.absoluteString,
                    let url = feed.feedData?.link
                {
                    HStack {
                        Button {
                            openURL(url)
                        } label: {
                            Text(linkDisplayString).lineLimit(1)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("open-webpage-button")
                        
                        Button {
                            PasteboardUtility.copyURL(url: url)
                            webpageCopied = true
                            feedAddressCopied = false
                        } label: {
                            Label {
                                Text("Copy", comment: "Button label.")
                            } icon: {
                                Image(systemName: "doc.on.doc")
                            }
                            .labelStyle(.iconOnly)

                            if webpageCopied {
                                Text("Copied", comment: "Copied to pasteboard message.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("copy-webpage-button")
                    }
                    
                }

                if let url = feed.url {
                    HStack {
                        Button {
                            openURL(url)
                        } label: {
                            Text(url.absoluteString).lineLimit(1)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("open-feed-address-button")
                        
                        Button {
                            PasteboardUtility.copyURL(url: url)
                            feedAddressCopied = true
                            webpageCopied = false
                        } label: {
                            Label {
                                Text("Copy", comment: "Button label.")
                            } icon: {
                                Image(systemName: "doc.on.doc")
                            }
                            .labelStyle(.iconOnly)

                            if feedAddressCopied {
                                Text("Copied", comment: "Copied to pasteboard message.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("copy-feed-address-button")
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
