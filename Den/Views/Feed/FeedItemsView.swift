//
//  FeedItemsView.swift
//  Den
//
//  Created by Garrett Johnson on 2/15/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

import Kingfisher

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
            if feed.feedData?.linkDisplayString != nil {
                Button {
                    linkManager.openLink(url: feed.feedData?.link)
                } label: {
                    HStack {
                        Label {
                            Text(feed.feedData!.linkDisplayString!)
                        } icon: {
                            KFImage(feed.feedData?.favicon)
                                .placeholder({ _ in
                                    Image(systemName: "globe")
                                })
                                .resizing(referenceSize: ImageSize.favicon)
                                .scaleFactor(UIScreen.main.scale)
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
}
