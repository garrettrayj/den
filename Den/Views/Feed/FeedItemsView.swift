//
//  FeedItemsView.swift
//  Den
//
//  Created by Garrett Johnson on 2/15/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedItemsView: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var linkManager: LinkManager

    @ObservedObject var feed: Feed

    @Binding var hideRead: Bool

    var frameSize: CGSize

    var body: some View {
        if feed.hasContent {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                Section(header: header.modifier(PinnedSectionHeaderModifier())) {
                    if hideRead == true && feed.feedData!.unreadItems.isEmpty {
                        Label("No unread items", systemImage: "checkmark")
                            .imageScale(.small)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(8)
                            .padding()
                    } else {
                        BoardView(
                            width: frameSize.width,
                            list: visibleItems
                        ) { item in
                            ItemPreviewView(item: item).modifier(GroupBlockModifier())
                        }.padding()
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom)
        } else {
            VStack {
                Spacer()
                FeedUnavailableView(feedData: feed.feedData, useStatusBox: true)
                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: frameSize.height - 24)
            .padding()
        }
    }

    private var header: some View {
        HStack {
            if feed.feedData?.linkDisplayString != nil {
                Button {
                    linkManager.openLink(url: feed.feedData?.link)
                } label: {
                    HStack {
                        Label {
                            Text(feed.feedData!.linkDisplayString!)
                        } icon: {
                            WebImage(url: feed.feedData?.favicon)
                                .resizable()
                                .placeholder {
                                    Image(systemName: "globe")
                                }
                                .frame(width: ImageSize.favicon.width, height: ImageSize.favicon.height)
                        }
                        Spacer()
                        Image(systemName: "link")
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .imageScale(.small)
                            .font(.body.weight(.semibold))

                    }
                    .padding(.horizontal, 28)
                }
                .buttonStyle(
                    FeedTitleButtonStyle(backgroundColor: Color(UIColor.tertiarySystemGroupedBackground))
                )
            } else {
                Label {
                    Text("Website Unknown").font(.caption)
                } icon: {
                    Image(systemName: "questionmark.square")
                }
                .foregroundColor(.secondary)
                .padding(.leading, 28)
                .padding(.trailing, 8)
            }
        }
        .lineLimit(1)
    }

    private var visibleItems: [Item] {
        guard let feedData = feed.feedData else { return [] }

        return feedData.limitedItemsArray.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
