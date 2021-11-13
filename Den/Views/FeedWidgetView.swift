//
//  FeedWidgetView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedWidgetView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @Binding var activeFeed: String?

    @ObservedObject var viewModel: FeedWidgetViewModel

    var body: some View {
        widgetContent
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))

            )
    }

    private var widgetContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            feedHeader
            if viewModel.feed.feedData != nil && viewModel.feed.feedData!.itemsArray.count > 0 {
                feedItems
            } else {
                Divider()

                if viewModel.feed.feedData == nil {
                    feedNotFetched
                } else if viewModel.feed.feedData?.error != nil {
                    feedError
                } else if viewModel.feed.feedData!.itemsArray.count == 0 {
                    feedEmpty
                } else {
                    feedStatusUnknown
                }
            }
        }
    }

    private var feedHeader: some View {
        NavigationLink(tag: viewModel.feed.id!.uuidString, selection: $activeFeed) {
            FeedView(
                viewModel: FeedViewModel(feed: viewModel.feed),
                activeFeed: $activeFeed
            )
        } label: {
            FeedTitleLabelView(feed: viewModel.feed)
        }
        .buttonStyle(WidgetHeaderButtonStyle())
    }

    private var feedItems: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.feed.feedData!.itemsArray.prefix(viewModel.feed.page?.wrappedItemsPerFeed ?? 5)) { item in
                Group {
                    Divider()
                    FeedWidgetRowView(
                        item: item,
                        feed: viewModel.feed
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
                Text(viewModel.feed.feedData!.error!)
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
        .padding(.bottom, 2)
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
