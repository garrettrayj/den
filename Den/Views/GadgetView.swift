//
//  GadgetView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetView: View {
    @ObservedObject var viewModel: FeedViewModel

    var body: some View {
        widgetContent
            .modifier(GroupBlockModifier())
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
        HStack {
            if viewModel.feed.id != nil {
                NavigationLink {
                    FeedView(viewModel: viewModel)
                } label: {
                    FeedTitleLabelView(feed: viewModel.feed)
                }
                .buttonStyle(GadgetHeaderButtonStyle())
            }
            Spacer()
            if viewModel.refreshing {
                ProgressView().progressViewStyle(IconProgressStyle())
            }
        }.padding(.horizontal, 12)
    }

    private var feedItems: some View {
        return VStack(spacing: 0) {
            ForEach(viewModel.feed.feedData!.itemsArray.prefix(viewModel.feed.wrappedPreviewLimit)) { item in
                Group {
                    Divider()
                    GadgetItemView(
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
        #if targetEnvironment(macCatalyst)
        Text("Refresh to load feed")
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
        #else
        Text("Pull to refresh feed")
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
        #endif
    }

    private var feedStatusUnknown: some View {
        Text("Status unavailable")
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
    }
}
