//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

import SDWebImageSwiftUI

struct FeedView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.useInbuiltBrowser) private var useInbuiltBrowser

    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool
    @Binding var hideRead: Bool

    @AppStorage("FeedPreviewStyle_NA") private var previewStyle = PreviewStyle.compressed

    init(feed: Feed, profile: Profile, refreshing: Binding<Bool>, hideRead: Binding<Bool>) {
        self.feed = feed
        self.profile = profile

        _refreshing = refreshing
        _hideRead = hideRead

        _previewStyle = AppStorage(
            wrappedValue: PreviewStyle.compressed,
            "FeedPreviewStyle_\(feed.id?.uuidString ?? "NA")"
        )
    }

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
                        sortDescriptors: [NSSortDescriptor(keyPath: \Item.published, ascending: false)],
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

                        if items.count > feed.wrappedItemLimit {
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
            .toolbar {
                ToolbarItemGroup {
                    PreviewStyleButtonView(previewStyle: $previewStyle)
                    NavigationLink(value: DetailPanel.feedSettings(feed)) {
                        Label("Feed Settings", systemImage: "wrench")
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .accessibilityIdentifier("feed-settings-button")
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    FeedBottomBarView(
                        feed: feed,
                        profile: profile,
                        refreshing: $refreshing,
                        hideRead: $hideRead
                    )
                }
            }
            .onChange(of: feed.page) { _ in
                dismiss()
            }
            .navigationTitle(feed.wrappedTitle)
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
