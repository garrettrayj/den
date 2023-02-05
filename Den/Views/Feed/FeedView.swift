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
        GeometryReader { geometry in
            ScrollView(.vertical) {
                if feed.hasContent {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                        VStack(spacing: 0) {
                            WebImage(url: feed.feedData?.banner ?? feed.feedData?.image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(8)
                                .shadow(radius: 3, x: 1, y: 2)
                                .frame(maxWidth: 360, maxHeight: 180)
                                .padding(.horizontal)
                                .padding(.vertical, 20)
                        }
                        .frame(maxWidth: .infinity)
                        .background {
                            WebImage(url: feed.feedData?.banner ?? feed.feedData?.image)
                                .resizable()
                                .scaledToFill()
                                .overlay(.regularMaterial)
                        }
                        .clipped()

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
                                Text("Top Items").font(.title3)
                                Spacer()
                                if let refreshedTimeAgo = feed.feedData!.refreshedRelativeDateTimeString {
                                    Text("Refreshed \(refreshedTimeAgo)").font(.footnote)
                                }
                            }
                            .padding(.horizontal, 24)
                            .modifier(PinnedSectionHeaderModifier())
                        }

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
                            Text("More Items")
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                                .modifier(PinnedSectionHeaderModifier())
                        }

                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                if let linkDisplayString = feed.feedData?.linkDisplayString {
                                    Button {
                                        if useInbuiltBrowser {
                                            SafariUtility.openLink(url: feed.feedData?.link)
                                        } else {
                                            if let url = feed.feedData?.link {
                                                openURL(url)
                                            }
                                        }
                                    } label: {
                                        Label("\(linkDisplayString)", systemImage: "globe")
                                        Image(systemName: "link").imageScale(.small)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Label("Website Not Available", systemImage: "globe")
                                }

                                Button {
                                    UIPasteboard.general.string = feed.url!.absoluteString
                                } label: {
                                    HStack {
                                        Label("\(feed.urlString)", systemImage: "dot.radiowaves.up.forward")
                                        Image(systemName: "doc.on.doc").imageScale(.small)
                                    }
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("feed-copy-url-button")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(8)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        } header: {
                            Text("Feed Info")
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                                .modifier(PinnedSectionHeaderModifier())
                        }
                    }
                    Spacer()
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
