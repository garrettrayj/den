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
                        Section {
                            if hideRead == true && feed.feedData!.itemsArray.unread().isEmpty {
                                AllReadStatusView(hiddenCount: feed.feedData!.itemsArray.read().count)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(8)
                                    .padding()
                            } else {
                                BoardView(
                                    width: geometry.size.width,
                                    list: feed.feedData?.visibleItems(hideRead) ?? []
                                ) { item in
                                    ItemActionView(item: item) {
                                        ItemPreviewView(item: item)
                                    }
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(8)
                                }
                            }
                        } header: {
                            header.modifier(PinnedSectionHeaderModifier())
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

    private var header: some View {
        HStack {
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
                    HStack {
                        Label {
                            Text(linkDisplayString)
                        } icon: {
                            FeedFaviconView(url: feed.feedData?.favicon, placeholderSymbol: "globe")
                        }
                        Spacer()
                        Image(systemName: "link")
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .imageScale(.small)
                            .font(.body.weight(.semibold))

                    }
                }
                .buttonStyle(PinnedHeaderButtonStyle())
            } else {
                Label {
                    Text("Website unknown").font(.caption)
                } icon: {
                    Image(systemName: "questionmark.square")
                }
                .foregroundColor(.secondary)
                .padding(.leading, 20)
                .padding(.trailing, 8)
            }
        }
        .lineLimit(1)
    }
}
