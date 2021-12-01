//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

enum PageViewMode: Int {
    case gadgets = 0
    case showcase = 1
}

struct PageView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscribeManager: SubscribeManager

    @ObservedObject var viewModel: PageViewModel

    @State var showingSettings: Bool = false

    @AppStorage("pageViewModel_na") var viewMode = PageViewMode.gadgets.rawValue

    init(viewModel: PageViewModel) {
        self.viewModel = viewModel

        _viewMode = AppStorage(
            wrappedValue: PageViewMode.gadgets.rawValue,
            "pageViewModel_\(viewModel.page.id?.uuidString ?? "na")"
        )
    }

    var body: some View {
        Group {
            if viewModel.page.managedObjectContext == nil {
                pageRemoved
            } else if viewModel.page.feedsArray.count == 0 {
                pageEmpty
            } else {
                #if targetEnvironment(macCatalyst)
                ScrollView(.vertical, showsIndicators: false) {
                    pageContent
                }
                #else
                RefreshableScrollView(
                    refreshing: $viewModel.refreshing,
                    onRefresh: { _ in
                        refresh()
                    },
                    content: { pageContent }
                )
                #endif
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .background(
            Group {
                NavigationLink(
                    destination: PageSettingsView(page: viewModel.page),
                    isActive: $showingSettings
                ) {
                    EmptyView()
                }

                // Hidden button for iOS keyboard shortcut
                #if !targetEnvironment(macCatalyst)
                Button(action: refresh) {
                    EmptyView()
                }.keyboardShortcut("r", modifiers: [.command])
                #endif
            }
        )
        .navigationTitle(viewModel.page.displayName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            #if targetEnvironment(macCatalyst)
            ToolbarItem {
                Picker("View Mode", selection: $viewMode) {
                    Label("Gadgets", systemImage: "square.grid.2x2")
                        .tag(PageViewMode.gadgets.rawValue)
                    Label("Showcase", systemImage: "square.grid.3x1.below.line.grid.1x2")
                        .tag(PageViewMode.showcase.rawValue)
                }
                .pickerStyle(.segmented)
            }
            ToolbarItem {
                Button(action: showSubscribe) {
                    Label("Add Subscription", systemImage: "plus.circle")
                }
            }
            ToolbarItem {
                Button(action: showSettings) {
                    Label("Page Settings", systemImage: "wrench")
                }
            }
            ToolbarItem {
                Button(action: refresh) {
                    if viewModel.refreshing {
                        ProgressView().progressViewStyle(NavigationBarProgressStyle())
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }.keyboardShortcut("r", modifiers: [.command])
            }
            #else
            ToolbarItem {
                Menu {
                    Button(action: showSubscribe) {
                        Label("Add Subscription", systemImage: "plus.circle")
                    }
                    Button(action: showSettings) {
                        Label("Page Settings", systemImage: "wrench")
                    }
                    if viewMode == PageViewMode.gadgets.rawValue {
                        Button {
                            viewMode = PageViewMode.showcase.rawValue
                        } label: {
                            Label("Showcase View", systemImage: "square.grid.3x1.below.line.grid.1x2")
                        }
                    } else {
                        Button {
                            viewMode = PageViewMode.gadgets.rawValue
                        } label: {
                            Label("Gadgets View", systemImage: "square.grid.2x2")
                        }
                    }
                } label: {
                    Label("Page Menu", systemImage: "ellipsis")
                }.buttonStyle(NavigationBarButtonStyle())
            }
            #endif
        }
        .onAppear {
            subscribeManager.currentPageId = viewModel.page.id?.uuidString
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .pageDeleted, object: viewModel.page.objectID)
        ) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
        }
    }

    private var pageContent: some View {
        Group {
            if viewMode == PageViewMode.gadgets.rawValue {
                widgetGrid
            } else {
                showcaseStack
            }
        }
    }

    private var widgetGrid: some View {
        BoardView(list: viewModel.page.feedsArray, content: { feed in
            GadgetView(viewModel: FeedViewModel(feed: feed, refreshing: viewModel.refreshing))
        })
        .padding(.horizontal)
        .padding(.bottom)
    }

    private var showcaseStack: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            ForEach(viewModel.page.feedsArray) { feed in
                ShowcaseSectionView(viewModel: FeedViewModel(feed: feed, refreshing: viewModel.refreshing))
            }
        }
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

    private var pageRemoved: some View {
        Text("This page no longer exists")
            .modifier(SimpleMessageModifier())
            .navigationTitle("Page Removed")
    }

    private func refresh() {
        refreshManager.refresh(page: viewModel.page)
    }

    private func showSettings() {
        showingSettings = true
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
