//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var linkManager: LinkManager

    @ObservedObject var viewModel: FeedViewModel

    @State private var showingSettings: Bool = false

    var feedData: FeedData? {
        viewModel.feed.feedData
    }

    var body: some View {
        Group {
            GeometryReader { geometry in
                #if targetEnvironment(macCatalyst)
                ScrollView(.vertical) { feedContent(frameSize: geometry.size) }
                #else
                RefreshableScrollView(
                    onRefresh: { done in
                        refreshManager.refresh(feed: viewModel.feed)
                        done()
                    },
                    content: { feedContent(width: geometry.size.width) }
                )
                #endif
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .background(
            NavigationLink(
                destination: FeedSettingsView(viewModel: viewModel),
                isActive: $showingSettings
            ) {
                EmptyView()
            }
        )
        .navigationTitle(viewModel.feed.wrappedTitle)
        .toolbar {
            ToolbarItem {
                Button {
                    showingSettings = true
                } label: {
                    Label("Feed Settings", systemImage: "wrench")
                }
                .buttonStyle(ToolbarButtonStyle())
                .disabled(refreshManager.isRefreshing)
                .accessibilityIdentifier("feed-settings-button")
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.refreshing {
                    ProgressView().progressViewStyle(ToolbarProgressStyle())
                } else {
                    Button {
                        refreshManager.refresh(feed: viewModel.feed)
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .keyboardShortcut("r", modifiers: [.command])
                    .disabled(refreshManager.isRefreshing)
                    .accessibilityIdentifier("feed-refresh-button")
                }
            }
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

    @ViewBuilder
    private func feedContent(frameSize: CGSize) -> some View {
        if feedData != nil && feedData!.itemsArray.count > 0 {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                Section(header: header.modifier(PinnedSectionHeaderModifier())) {
                    BoardView(
                        width: frameSize.width,
                        list: feedData!.limitedItemsArray
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
}
