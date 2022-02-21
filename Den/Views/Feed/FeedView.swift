//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var viewModel: FeedViewModel

    @State var showingSettings: Bool = false

    var body: some View {
        Group {
            if viewModel.feed.managedObjectContext == nil {
                StatusBoxView(message: Text("Feed Deleted"), symbol: "slash.circle")
                    .navigationTitle("")
            } else {
                GeometryReader { geometry in
                    #if targetEnvironment(macCatalyst)
                    ScrollView(.vertical) { FeedItemsView(feed: viewModel.feed, frameSize: geometry.size) }
                    #else
                    RefreshableScrollView(
                        onRefresh: { done in
                            refreshManager.refresh(feed: viewModel.feed)
                            done()
                        },
                        content: { FeedItemsView(feed: viewModel.feed, frameSize: geometry.size) }
                    )
                    #endif
                }
                .toolbar {
                    ToolbarItem {
                        Button {
                            showingSettings = true
                        } label: {
                            Label("Feed Settings", systemImage: "wrench")
                        }
                        .buttonStyle(ToolbarButtonStyle())
                        .disabled(viewModel.refreshing)
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
                                .accessibilityIdentifier("feed-refresh-button")
                            }
                        }.modifier(TrailingToolbarItemModifier())
                    }
                }
            }
        }
        .disabled(viewModel.refreshing)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .background(
            NavigationLink(
                destination: FeedSettingsView(viewModel: FeedSettingsViewModel(
                    viewContext: viewContext, crashManager: crashManager, feed: viewModel.feed
                )),
                isActive: $showingSettings
            ) {
                EmptyView()
            }
        )
        .navigationTitle(viewModel.feed.wrappedTitle)

    }
}
