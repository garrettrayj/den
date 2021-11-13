//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageView: View {
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscribeManager: SubscribeManager

    @ObservedObject var viewModel: PageViewModel

    let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 16, alignment: .top)
    ]

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.page.managedObjectContext == nil {
                pageDeleted
            } else if viewModel.page.feedsArray.count == 0 {
                pageEmpty
            } else {
                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        RefreshableScrollView(viewModel: viewModel) {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.page.feedsArray) { feed in
                                    FeedWidgetView(
                                        activeFeed: $viewModel.activeFeed,
                                        viewModel: FeedWidgetViewModel(
                                            feed: feed,
                                            pageViewModel: viewModel
                                        )
                                    )
                                }
                            }
                            .padding(.leading, horizontalInset(geometry.safeAreaInsets.leading))
                            .padding(.trailing, horizontalInset(geometry.safeAreaInsets.trailing))
                            .padding(.top, 8)
                            .padding(.bottom, 40)
                        }
                        HeaderProgressBarView(
                            refreshing: $viewModel.refreshing,
                            fractionCompleted: $viewModel.refreshFractionCompleted
                        )
                    }
                    .edgesIgnoringSafeArea(.horizontal)
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        .background(NavigationLink(
            destination: PageSettingsView(viewModel: PageSettingsViewModel(page: viewModel.page)),
            isActive: $viewModel.showingSettings
        ) {
            EmptyView()
        })
        .navigationTitle(viewModel.page.displayName)
        .toolbar { pageToolbar }
        .onAppear {
            subscribeManager.currentPageId = viewModel.page.id?.uuidString
        }
    }

    private var pageToolbar: some ToolbarContent {
        ToolbarItemGroup {
            if viewModel.page.managedObjectContext != nil {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    compactPageToolbar
                } else {
                    fullPageToolbar
                }
            }
        }
    }

    private var compactPageToolbar: some View {
        Menu {
            Button(action: showSubscribe) {
                Label("Add Subscription", systemImage: "plus.circle")
            }

            Button(action: showSettings) {
                Label("Page Settings", systemImage: "wrench")
            }

            Button {
                refreshManager.refresh(pageViewModel: viewModel)
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
        } label: {
            Label("Page Menu", systemImage: "ellipsis")
                .frame(height: 44)
                .padding(.horizontal, 12)
                .background(Color.clear)
        }
    }

    private var fullPageToolbar: some View {
        HStack(spacing: 0) {
            Button(action: showSubscribe) {
                Label("Add Subscription", systemImage: "plus.circle")
            }.disabled(viewModel.refreshing)

            Button(action: showSettings) {
                Label("Page Settings", systemImage: "wrench")
            }.disabled(viewModel.refreshing)

            if viewModel.refreshing {
                ProgressView(value: 0).progressViewStyle(ToolbarProgressStyle())
            } else {
                Button {
                    refreshManager.refresh(pageViewModel: viewModel)
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }.buttonStyle(ToolbarButtonStyle())
    }

    private var pageEmpty: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .phone {
                Text("Tap \(Image(systemName: "ellipsis.circle")) to add a subscription")
                    .modifier(SimpleMessageModifier())
            } else {
                Text("Tap \(Image(systemName: "plus.circle")) to add a subscription")
                    .modifier(SimpleMessageModifier())
            }
        }
    }

    private var pageDeleted: some View {
        Text("Page no longer exists")
            .modifier(SimpleMessageModifier())
            .navigationTitle("Page Deleted")
    }

    private func showSettings() {
        viewModel.showingSettings = true
    }

    private func showSubscribe() {
        subscribeManager.showAddSubscription()
    }

    private func horizontalInset(_ safeArea: CGFloat) -> CGFloat {
        if safeArea > 0 {
            return safeArea
        }

        return 16
    }
}
