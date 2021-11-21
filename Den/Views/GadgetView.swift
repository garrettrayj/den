//
//  GadgetView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetView: View {
    @ObservedObject var feed: Feed

    @State var refreshing: Bool

    var body: some View {
        widgetContent
            .background(
                RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground))
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .feedQueued, object: feed.objectID)
            ) { _ in
                refreshing = true
            }.onReceive(
                NotificationCenter.default.publisher(for: .feedRefreshed, object: feed.objectID)
            ) { _ in
                refreshing = false
                feed.objectWillChange.send()
            }.onReceive(
                NotificationCenter.default.publisher(for: .pageRefreshed, object: feed.page?.objectID)
            ) { _ in
                refreshing = false
            }
    }

    private var widgetContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            feedHeader
            if feed.feedData != nil && feed.feedData!.itemsArray.count > 0 {
                feedItems
            } else {
                Divider()

                if feed.feedData == nil {
                    feedNotFetched
                } else if feed.feedData?.error != nil {
                    feedError
                } else if feed.feedData!.itemsArray.count == 0 {
                    feedEmpty
                } else {
                    feedStatusUnknown
                }
            }
        }
    }

    private var feedHeader: some View {
        HStack {
            if feed.id != nil {
                NavigationLink {
                    FeedView(feed: feed, refreshing: $refreshing)
                } label: {
                    FeedTitleLabelView(feed: feed)
                }
                .buttonStyle(GadgetHeaderButtonStyle())
            }
            Spacer()
            if refreshing {
                ProgressView().progressViewStyle(IconProgressStyle()).padding(.trailing, 8)
            }
        }
    }

    private var feedItems: some View {
        VStack(spacing: 0) {
            ForEach(feed.feedData!.itemsArray.prefix(feed.page?.wrappedItemsPerFeed ?? 5)) { item in
                Group {
                    Divider()
                    GadgetItemView(
                        item: item,
                        feed: feed
                    )
                }
            }
        }
    }

    private var feedError: some View {
        VStack {
            VStack(spacing: 4) {
                Text("Unable to update feed")
                    .foregroundColor(.secondary)
                    .font(.callout)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(feed.feedData!.error!)
                    .foregroundColor(.red)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(lineWidth: 1)
                .foregroundColor(.red)
        )
        .padding([.horizontal, .top])
        .padding(.bottom)
    }

    private var feedEmpty: some View {
        Text("Feed empty")
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
    }

    private var feedNotFetched: some View {
        Text("Refresh to fetch content")
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
    }

    private var feedStatusUnknown: some View {
        Text("Feed status unavailable")
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
    }
}
