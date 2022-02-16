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

    @ObservedObject var viewModel: FeedViewModel

    @State private var showingSettings: Bool = false

    var body: some View {
        Group {
            GeometryReader { geometry in
                #if targetEnvironment(macCatalyst)
                ScrollView(.vertical) { FeedItemsView(viewModel: viewModel, frameSize: geometry.size) }
                #else
                RefreshableScrollView(
                    onRefresh: { done in
                        refreshManager.refresh(feed: viewModel.feed)
                        done()
                    },
                    content: { FeedItemsView(viewModel: viewModel, frameSize: geometry.size) }
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
                Group {
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
                }.padding(.trailing, 8)

            }
        }
    }
}
