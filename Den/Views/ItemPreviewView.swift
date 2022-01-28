//
//  ItemPreviewView.swift
//  Den
//
//  Created by Garrett Johnson on 12/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemPreviewView: View {
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var linkManager: LinkManager

    @ObservedObject var item: Item

    var feedViewModel: FeedViewModel?
    var summaryLines: Int = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if feedViewModel != nil {
                NavigationLink {
                    FeedView(viewModel: feedViewModel!)
                } label: {
                    FeedTitleLabelView(
                        title: feedViewModel!.feed.wrappedTitle,
                        faviconImage: feedViewModel!.feed.feedData?.faviconImage
                    )
                }
                .buttonStyle(FeedTitleButtonStyle())
                .disabled(refreshManager.isRefreshing)

                Divider()
            }

            Button {
                linkManager.openLink(
                    url: item.link,
                    logHistoryItem: item,
                    readerMode: item.feedData?.feed?.readerMode ?? false
                )
            } label: {
                Text(item.wrappedTitle)
            }
            .buttonStyle(ItemButtonStyle(read: item.read))
            .accessibility(identifier: "Item Link")

            if item.published != nil {
                Text("\(item.published!, formatter: DateFormatter.mediumShort)")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }

            if item.feedData?.feed?.showThumbnails == true && item.previewUIImage != nil {
                Image(uiImage: item.previewUIImage!)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: CGFloat(item.imageWidth), maxHeight: CGFloat(item.imageHeight))
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(UIColor.opaqueSeparator), lineWidth: 1)
                    )
                    .accessibility(label: Text("Preview Image"))
            }

            if item.summary != nil && item.summary != "" {
                Text(item.summary!).lineLimit(6)
            }

            Spacer()
        }
        .padding(.top, feedViewModel != nil ? 8 : 12)
        .padding([.horizontal], 12)
        .modifier(GroupBlockModifier())
    }
}
