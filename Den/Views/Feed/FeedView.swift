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
    @Environment(\.contentSizeCategory) private var contentSizeCategory
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ObservedObject var feed: Feed

    @Binding var hideRead: Bool

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                if feed.hasContent {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                        if let heroImage = feed.feedData?.banner ?? feed.feedData?.image {
                            FeedHeroView(heroImage: heroImage)
                        }

                        Section {
                            if hideRead == true && feed.feedData!.previewItems.unread().isEmpty {
                                AllReadStatusView(hiddenCount: feed.feedData!.previewItems.read().count)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(8)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                            } else {
                                BoardView(
                                    width: geometry.size.width,
                                    list: feed.feedData?.visiblePreviewItems(hideRead) ?? []
                                ) { item in
                                    ItemActionView(item: item) {
                                        ItemPreviewView(item: item)
                                    }
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(8)
                                }
                            }
                        } header: {
                            HStack {
                                Text("Latest").font(.title3)
                                Spacer()
                                if let refreshedTimeAgo = feed.feedData!.refreshedRelativeDateTimeString {
                                    Text("Updated \(refreshedTimeAgo)").font(.callout)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .modifier(PinnedSectionHeaderModifier())
                        }

                        if feed.feedData!.extraItems.isEmpty == false {
                            Section {
                                if hideRead == true && feed.feedData!.extraItems.unread().isEmpty {
                                    AllReadStatusView(hiddenCount: feed.feedData!.extraItems.read().count)
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .cornerRadius(8)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                } else {
                                    BoardView(
                                        width: geometry.size.width,
                                        list: feed.feedData?.visibleExtraItems(hideRead) ?? []
                                    ) { item in
                                        GadgetItemView(item: item)
                                            .background(Color(UIColor.secondarySystemGroupedBackground))
                                            .cornerRadius(8)
                                    }
                                }
                            } header: {
                                Text("More")
                                    .font(.title3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)
                                    .modifier(PinnedSectionHeaderModifier())
                            }
                        }

                        Divider()

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
                            .dynamicTypeSize(DynamicTypeSize(contentSizeCategory) ?? dynamicTypeSize)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 24)
                            .padding(.vertical)
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        FeedUnavailableView(feedData: feed.feedData, splashNote: true)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height)
                }
            }
        }
        .toolbar {
            ToolbarItem {
                NavigationLink(value: DetailPanel.feedSettings(feed)) {
                    Label("Feed Settings", systemImage: "wrench")
                }
                .buttonStyle(ToolbarButtonStyle())
                .accessibilityIdentifier("feed-settings-button")
            }

            ToolbarItemGroup(placement: .bottomBar) {
                FeedBottomBarView(feed: feed, hideRead: $hideRead)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onChange(of: feed.page) { _ in
            dismiss()
        }
        .navigationTitle(feed.wrappedTitle)
    }
}
