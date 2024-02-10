//
//  FeedLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct FeedLayout: View {
    @Environment(\.openURL) private var openURL

    @ObservedObject var feed: Feed

    @Binding var hideRead: Bool

    @State private var feedAddressCopied: Bool = false

    let items: FetchedResults<Item>

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    if let heroImage = feed.feedData?.banner {
                        FeedHero(url: heroImage)
                    }
                    
                    if feed.feedData == nil || feed.feedData?.wrappedError != nil {
                        FeedUnavailable(feed: feed, largeDisplay: true)
                    } else if items.isEmpty {
                        FeedEmpty(largeDisplay: true).padding()
                    } else if items.unread().isEmpty && hideRead {
                        AllRead(largeDisplay: true).padding()
                    } else {
                        if !items.featured().isEmpty {
                            FeedLayoutSection(
                                feed: feed,
                                hideRead: $hideRead,
                                geometry: geometry,
                                items: items.featured()
                            ) {
                                Label {
                                    Text("Featured", comment: "Feed view section header.")
                                } icon: {
                                    Image(systemName: "lamp.desk")
                                }
                            }
                        }
                        
                        if !items.extra().isEmpty {
                            FeedLayoutSection(
                                feed: feed,
                                hideRead: $hideRead,
                                geometry: geometry,
                                items: items.extra()
                            ) {
                                Label {
                                    Text("Extra", comment: "Feed view section header.")
                                } icon: {
                                    Image(systemName: "archivebox")
                                }
                            }
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
                Button {
                    openURL(url)
                } label: {
                    Text(linkDisplayString).lineLimit(1)
                }
            }

            if let url = feed.url {
                HStack {
                    Button {
                        PasteboardUtility.copyURL(url: url)
                        feedAddressCopied = true
                    } label: {
                        Label {
                            Text(url.absoluteString).lineLimit(1)
                        } icon: {
                            Image(systemName: "doc.on.doc")
                        }

                        if feedAddressCopied {
                            Text("Copied", comment: "Copied to pasteboard message.")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityIdentifier("CopyFeedAddress")
                }
            }

            if let copyright = feed.feedData?.copyright {
                Text(copyright)
            }
        }
        .buttonStyle(.borderless)
        .textSelection(.enabled)
        .font(.footnote)
        .imageScale(.small)
        .multilineTextAlignment(.center)
        .padding()
    }
}
