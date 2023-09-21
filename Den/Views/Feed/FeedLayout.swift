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

    @State private var feedAddressCopied: Bool = false

    let items: [Item]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    if feed.feedData == nil || feed.feedData?.error != nil {
                        FeedUnavailable(feedData: feed.feedData, largeDisplay: true)
                    } else {
                        if let heroImage = feed.feedData?.banner {
                            FeedHero(heroImage: heroImage)
                            Divider()
                        }

                        if items.isEmpty {
                            FeedEmpty(largeDisplay: true)
                        } else if items.unread().isEmpty && hideRead {
                            AllRead(largeDisplay: true)
                        } else {
                            BoardView(
                                width: geometry.size.width,
                                list: items.visibilityFiltered(hideRead ? false : nil)
                            ) { item in
                                ItemActionView(item: item, feed: feed, profile: profile) {
                                    if feed.wrappedPreviewStyle == .expanded {
                                        ItemPreviewExpanded(item: item, feed: feed)
                                    } else {
                                        ItemPreviewCompressed(item: item, feed: feed)
                                    }
                                }
                                .modifier(RoundedContainerModifier())
                            }
                            .modifier(SafeAreaModifier(geometry: geometry))
                        }
                    }

                    Divider()
                    metaSection.modifier(SafeAreaModifier(geometry: geometry))
                }
            }
            .edgesIgnoringSafeArea(.horizontal)
        }
    }

    private var metaSection: some View {
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
                    .accessibilityIdentifier("OpenWebpage")
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
                    .accessibilityIdentifier("OpenFeedAddress")

                    Button {
                        PasteboardUtility.copyURL(url: url)
                        feedAddressCopied = true
                    } label: {
                        Label {
                            Text("Copy", comment: "Button label.")
                        } icon: {
                            Image(systemName: "doc.on.doc")
                        }
                        .labelStyle(.iconOnly)

                        if feedAddressCopied {
                            Text("Copied", comment: "Copied to pasteboard message.")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("CopyFeedAddress")
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
        .padding()
    }
}
