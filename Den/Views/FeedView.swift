//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var linkManager: LinkManager

    @ObservedObject var viewModel: FeedViewModel

    @State var showingSettings: Bool = false

    var body: some View {
        Group {
            #if targetEnvironment(macCatalyst)
            ScrollView(.vertical) {
                feedContent
            }
            #else
            RefreshableScrollView(
                refreshing: $viewModel.refreshing,
                onRefresh: { _ in
                    refreshManager.refresh(feed: viewModel.feed)
                },
                content: { feedContent }
            )
            #endif
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

                // Hidden button for iOS keyboard shortcuts
                #if !targetEnvironment(macCatalyst)
                Button {
                    refreshManager.refresh(feed: viewModel.feed)
                } label: {
                    EmptyView()
                }
                .keyboardShortcut("r", modifiers: [.command])
                #endif
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
                .buttonStyle(NavigationBarButtonStyle())
                .disabled(viewModel.refreshing)
            }

            #if targetEnvironment(macCatalyst)
            ToolbarItem {
                Button {
                    refreshManager.refresh(feed: viewModel.feed)
                } label: {
                    if viewModel.refreshing {
                        ProgressView().progressViewStyle(NavigationBarProgressStyle())
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                .buttonStyle(NavigationBarButtonStyle())
                .keyboardShortcut("r", modifiers: [.command])
                .disabled(viewModel.refreshing)
            }
            #endif
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .feedWillBeDeleted, object: viewModel.feed.objectID)
        ) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
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
                        if viewModel.feed.feedData?.faviconImage != nil {
                            viewModel.feed.feedData!.faviconImage!
                                .scaleEffect(1 / UIScreen.main.scale)
                                .frame(width: 16, height: 16, alignment: .center)
                                .clipped()
                        }
                    }
                }
                .font(.callout)
                .foregroundColor(Color.primary)
            }

            Spacer()

            lastRefreshedLabel()
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .lineLimit(1)
    }

    private var feedContent: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            Section(header: feedHeader.modifier(PinnedSectionHeaderModifier())) {
                if viewModel.feed.feedData != nil && viewModel.feed.feedData!.itemsArray.count > 0 {
                    BoardView(list: viewModel.feed.feedData!.itemsArray, content: { item in
                        FeedItemView(item: item)
                    }).padding()
                } else {
                    if viewModel.feed.feedData == nil {
                        #if targetEnvironment(macCatalyst)
                        Text("Refresh to load feed").modifier(SimpleMessageModifier())
                        #else
                        Text("Pull to refresh feed").modifier(SimpleMessageModifier())
                        #endif
                    } else if viewModel.feed.feedData?.error != nil {
                        Text("Unable to update feed").modifier(SimpleMessageModifier())
                    } else if viewModel.feed.feedData!.itemsArray.count == 0 {
                        Text("Feed empty").modifier(SimpleMessageModifier())
                    } else {
                        Text("Status unavailable").modifier(SimpleMessageModifier())
                    }
                }
            }
        }
    }

    private func lastRefreshedLabel() -> Text {
        guard let lastRefreshed = viewModel.feed.feedData?.refreshed else {
            return Text("First refresh")
        }

        return Text("\(lastRefreshed, formatter: DateFormatter.mediumShort)")
    }
}
