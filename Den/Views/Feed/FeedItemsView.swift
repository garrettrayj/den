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

    @ObservedObject var viewModel: FeedViewModel

    var frameSize: CGSize

    var feedData: FeedData? {
        viewModel.feed.feedData
    }

    var body: some View {
        if feedData != nil && feedData!.itemsArray.count > 0 {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                Section(header: header.modifier(PinnedSectionHeaderModifier())) {
                    BoardView(
                        width: frameSize.width,
                        list: Array(feedData!.limitedItemsArray)
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
                FeedUnavailableView(feedData: feedData, useStatusBox: true)
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
            if feedData?.linkDisplayString != nil {
                Button {
                    linkManager.openLink(url: feedData?.link)
                } label: {
                    Label {
                        Text(feedData?.linkDisplayString ?? "")
                    } icon: {
                        if feedData?.faviconImage != nil {
                            feedData!.faviconImage!
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
                    .padding(.leading, 28)
                    .padding(.trailing, 8)
                }
                .buttonStyle(
                    FeedTitleButtonStyle(backgroundColor: Color(UIColor.tertiarySystemGroupedBackground))
                )
                .font(.callout)
                .foregroundColor(Color.primary)
            }
            Spacer()
            FeedRefreshedLabelView(refreshed: viewModel.feed.refreshed)
                .padding(.leading, 8)
                .padding(.trailing, 28)
        }
        .lineLimit(1)
    }
}
