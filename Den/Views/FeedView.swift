//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

import Grid

struct FeedView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var refreshManager: RefreshManager

    @ObservedObject var viewModel: FeedViewModel
    @Binding var activeFeed: String?

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.feed.feedData != nil && viewModel.feed.feedData!.itemsArray.count > 0 {
                feedItems
            } else {
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
            Spacer()
        }
        .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        .background(NavigationLink(
            destination: FeedSettingsView(
                activeFeed: $activeFeed,
                viewModel: FeedSettingsViewModel(
                    feed: viewModel.feed,
                    viewContext: viewContext,
                    crashManager: crashManager
                )
            ),
            isActive: $viewModel.showingSettings
        ) {
            EmptyView()
        })
        .onDisappear {
            activeFeed = nil
        }
        .navigationTitle(viewModel.feed.wrappedTitle)
        .toolbar { toolbar }
    }

    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                viewModel.showingSettings = true
            } label: {
                Label("Feed Settings", systemImage: "wrench")
            }.disabled(viewModel.refreshing).buttonStyle(ToolbarButtonStyle())

            if viewModel.refreshing {
                ProgressView(value: 0).progressViewStyle(ToolbarProgressStyle())
            } else {
                Button {
                    refreshManager.refresh(feedViewModel: viewModel)
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }.buttonStyle(ToolbarButtonStyle())
            }
        }
    }

    private var feedHeader: some View {
        HStack {
            FeedTitleLabelView(feed: viewModel.feed).font(.headline.weight(.medium))
        }.padding(.leading, 12)
    }

    private var feedItems: some View {
        ScrollView {
            HStack(alignment: .center, spacing: 8) {
                if viewModel.feed.feedData?.faviconImage != nil {
                    viewModel.feed.feedData!.faviconImage!
                        .scaleEffect(1 / UIScreen.main.scale)
                        .frame(width: 16, height: 16, alignment: .center)
                        .clipped()
                } else {
                    Image(uiImage: UIImage(named: "RSSIcon")!)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.secondary)
                        .frame(width: 14, height: 14, alignment: .center)
                }

                Text(viewModel.feed.feedData?.linkDisplayString ?? "Website not available")
                    .font(.callout)

                Spacer()

                lastRefreshedLabel()
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .lineLimit(1)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground))
            )
            .padding(.horizontal)
            .padding(.top, 8)

            Grid(viewModel.feed.feedData!.itemsArray, id: \.self) { item in
                FeedItemView(item: item)
            }
            .gridStyle(StaggeredGridStyle(.vertical, tracks: Tracks.min(240), spacing: 16))
            .padding(.top, 8)
            .padding(.horizontal, 16)
            .padding(.bottom, 64)
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

    private func lastRefreshedLabel() -> Text {
        guard let lastRefreshed = viewModel.feed.feedData?.refreshed else {
            return Text("First refresh")
        }

        return Text("\(lastRefreshed, formatter: DateFormatter.mediumShort)")
    }
}
