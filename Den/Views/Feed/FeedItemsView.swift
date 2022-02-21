//
//  FeedItemsView.swift
//  Den
//
//  Created by Garrett Johnson on 2/15/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedItemsView: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var linkManager: LinkManager

    @ObservedObject var feed: Feed

    var frameSize: CGSize

    var body: some View {
        if feed.feedData != nil && feed.feedData!.itemsArray.count > 0 {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                Section(header: header.modifier(PinnedSectionHeaderModifier())) {
                    BoardView(
                        width: frameSize.width,
                        list: Array(feed.feedData!.limitedItemsArray)
                    ) { item in
                        ItemPreviewView(item: item).modifier(GroupBlockModifier())
                    }.padding()
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 22)
        } else {
            VStack {
                Spacer()
                FeedUnavailableView(feedData: feed.feedData, useStatusBox: true)
                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: frameSize.height - 28)
            .padding()
        }
    }

    private var header: some View {
        HStack {
            Group {
                if feed.feedData?.linkDisplayString != nil {
                    Button {
                        linkManager.openLink(url: feed.feedData?.link)
                    } label: {
                        Label {
                            Text(feed.feedData?.linkDisplayString ?? "")
                        } icon: {
                            if feed.feedData?.faviconImage != nil {
                                feed.feedData!.faviconImage!
                                    .frame(
                                        width: ImageSize.favicon.width,
                                        height: ImageSize.favicon.height,
                                        alignment: .center
                                    )
                                    .clipped()
                            } else {
                                Image(systemName: "link")
                            }
                        }

                    }
                    .buttonStyle(
                        FeedTitleButtonStyle(backgroundColor: Color(UIColor.tertiarySystemGroupedBackground))
                    )
                } else {
                    Label {
                        Text("Website Unknown").font(.caption)
                    } icon: {
                        Image(systemName: "questionmark.square")
                    }.foregroundColor(.secondary)
                }
            }
            .padding(.leading, 28)
            .padding(.trailing, 8)

            Spacer()
            FeedRefreshedLabelView(refreshed: feed.refreshed)
                .padding(.leading, 8)
                .padding(.trailing, 28)
        }
        .lineLimit(1)
    }
}
