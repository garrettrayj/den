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

    @Binding var hideRead: Bool

    var body: some View {
        Group {
            WithItems(
                scopeObject: feed,
                sortDescriptors: [NSSortDescriptor(keyPath: \Item.published, ascending: false)],
                readFilter: hideRead ? false : nil
            ) { _, items in
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                            if let heroImage = feed.feedData?.banner {
                                FeedHeroView(heroImage: heroImage)
                            }
                            Section {
                                if feed.feedData == nil || feed.feedData?.error != nil {
                                    FeedUnavailableView(feedData: feed.feedData, splashNote: true)
                                } else if items.isEmpty {
                                    AllReadStatusView()
                                } else {
                                    BoardView(
                                        width: geometry.size.width,
                                        list: Array(items)
                                    ) { item in
                                        ItemActionView(item: item) {
                                            ItemExpandedView(item: item)
                                        }
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .cornerRadius(8)
                                    }.modifier(SectionContentPaddingModifier())
                                }
                            } header: {
                                HStack {
                                    Text("Latest").font(.title3)
                                    Spacer()
                                    if let refreshedTimeAgo = feed.feedData?.refreshedRelativeDateTimeString {
                                        Text("Updated \(refreshedTimeAgo).").font(.caption)
                                    }
                                }
                                .modifier(PinnedSectionHeaderModifier())
                            }

                            Divider()

                            metaSection
                        }
                    }
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
