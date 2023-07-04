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

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    if feed.feedData == nil || feed.feedData?.error != nil {
                        FeedUnavailable(feedData: feed.feedData)
                    } else {
                        if let heroImage = feed.feedData?.banner {
                            FeedHero(heroImage: heroImage)
                            Divider()
                        }
                        
                        if items.isEmpty {
                            FeedEmpty()
                        } else if items.unread().isEmpty && hideRead {
                            AllRead()
                                .modifier(SafeAreaModifier(geometry: geometry))
                        } else {
                            BoardView(
                                geometry: geometry,
                                list: items.visibilityFiltered(hideRead ? false : nil)
                            ) { item in
                                ItemActionView(item: item, feed: feed, profile: profile) {
                                    if feed.wrappedPreviewStyle == .expanded {
                                        ItemExpanded(item: item, feed: feed)
                                    } else {
                                        ItemCompressed(item: item, feed: feed)
                                    }
                                }
                                .modifier(RoundedContainerModifier())
                            }
                            .padding()
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
