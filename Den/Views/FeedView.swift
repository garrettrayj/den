//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var linkManager: LinkManager

    @ObservedObject var viewModel: FeedViewModel

    @State var showingSettings: Bool = false

    var body: some View {
        Group {
            if viewModel.feed.feedData != nil && viewModel.feed.feedData!.itemsArray.count > 0 {
                #if targetEnvironment(macCatalyst)
                ScrollView(.vertical) { feedContent }
                #else
                RefreshableScrollView(
                    onRefresh: { done in
                        refreshManager.refresh(feed: viewModel.feed)
                        done()
                    },
                    content: { feedContent }
                )
                #endif
            } else {
                FeedUnavailableView(feedData: viewModel.feed.feedData)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding()
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .background(
            Group {
                NavigationLink(
                    destination: FeedSettingsView(feed: viewModel.feed),
                    isActive: $showingSettings
                ) {
                    EmptyView()
                }
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
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    refreshManager.refresh(feed: viewModel.feed)
                } label: {
                    if viewModel.refreshing {
                        ProgressView().progressViewStyle(ToolbarProgressStyle())
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                .buttonStyle(ToolbarButtonStyle())
                .keyboardShortcut("r", modifiers: [.command])
                .disabled(refreshManager.isRefreshing)
            }
        }
    }

    private var feedHeader: some View {
        HStack {
            if viewModel.feed.feedData?.linkDisplayString != nil {
                Button {
                    linkManager.openLink(url: viewModel.feed.feedData?.link)
                } label: {
                    Label {
                        Text(viewModel.feed.feedData?.linkDisplayString ?? "")
                    } icon: {
                        viewModel.feed.feedData?.faviconImage?
                            .frame(
                                width: ImageSize.favicon.width,
                                height: ImageSize.favicon.height,
                                alignment: .center
                            )
                            .clipped()
                    }
                }
                .font(.callout)
                .foregroundColor(Color.primary)
            }
            Spacer()
            FeedRefreshedLabelView(refreshed: viewModel.feed.refreshed)
        }
        .lineLimit(1)
    }

    private var feedContent: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            Section(header: feedHeader.modifier(PinnedSectionHeaderModifier())) {
                BoardView(list: viewModel.feed.feedData!.itemsArray, content: { item in
                    ItemPreviewView(item: item)
                        .padding(.top)
                        .modifier(GroupBlockModifier())
                }).padding()
            }
        }
        #if targetEnvironment(macCatalyst)
        .padding(.top, 8)
        #endif
    }
}
