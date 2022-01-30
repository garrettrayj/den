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

    var feedData: FeedData? {
        viewModel.feed.feedData
    }

    var body: some View {
        Group {
            if feedData != nil && feedData!.itemsArray.count > 0 {
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
                FeedUnavailableView(feedData: feedData)
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
            if feedData?.linkDisplayString != nil {
                Button {
                    linkManager.openLink(url: feedData?.link)
                } label: {
                    Label {
                        Text(feedData?.linkDisplayString ?? "")
                    } icon: {
                        feedData?.faviconImage?
                            .frame(
                                width: ImageSize.favicon.width,
                                height: ImageSize.favicon.height,
                                alignment: .center
                            )
                            .clipped()
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

    private var feedContent: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            Section(header: feedHeader.modifier(PinnedSectionHeaderModifier())) {
                BoardView(list: feedData!.itemsArray, content: { item in
                    ItemPreviewView(item: item)
                        .modifier(GroupBlockModifier())
                }).padding()
            }
        }
        #if targetEnvironment(macCatalyst)
        .padding(.top, 8)
        #endif
    }
}
