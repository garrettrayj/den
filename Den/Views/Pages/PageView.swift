//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

enum PageViewMode: Int {
    case gadgets  = 0
    case showcase = 1
    case blend    = 2
}

struct PageView: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @ObservedObject var viewModel: PageViewModel

    @State private var showingSettings: Bool = false

    @AppStorage("pageViewMode_na") var viewMode = 0

    init(viewModel: PageViewModel) {
        self.viewModel = viewModel

        _viewMode = AppStorage(
            wrappedValue: PageViewMode.gadgets.rawValue,
            "pageViewMode_\(viewModel.page.id?.uuidString ?? "na")"
        )
    }

    #if targetEnvironment(macCatalyst)
    let emptyCaption = Text("""
    Add feeds by opening syndication links \
    or click \(Image(systemName: "plus.circle")) to add by web address
    """)
    #else
    let emptyCaption = Text("""
    Add feeds by opening syndication links \
    or tap \(Image(systemName: "ellipsis.circle")) then \(Image(systemName: "plus.circle")) \
    to add by web address
    """)
    #endif

    var body: some View {
        Group {
            if viewModel.page.managedObjectContext == nil {
                StatusBoxView(message: Text("Page Deleted"), symbol: "slash.circle")
                    .navigationTitle("")
            } else if viewModel.page.feedsArray.isEmpty {
                StatusBoxView(
                    message: Text("Page Empty"),
                    caption: emptyCaption,
                    symbol: "questionmark.square.dashed"
                )
            } else if viewModel.page.limitedItemsArray.isEmpty && viewMode == PageViewMode.blend.rawValue {
                StatusBoxView(
                    message: Text("No Items"),
                    caption: Text("Tap \(Image(systemName: "arrow.clockwise")) to refresh"),
                    symbol: "questionmark.square.dashed"
                )
            } else {
                #if targetEnvironment(macCatalyst)
                ScrollView(.vertical) {
                    displayContent
                }.toolbar { toolbarContent }
                #else
                RefreshableScrollView(
                    onRefresh: { done in
                        refreshManager.refresh(page: viewModel.page)
                        done()
                    },
                    content: { displayContent }
                ).toolbar { toolbarContent }
                #endif
            }
        }
        .onAppear {
            subscriptionManager.activePage = viewModel.page
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .background(
            Group {
                NavigationLink(
                    destination: PageSettingsView(viewModel: viewModel),
                    isActive: $showingSettings
                ) {
                    EmptyView()
                }
            }
        )
        .navigationTitle(viewModel.page.displayName)
        .navigationBarTitleDisplayMode(.large)

    }

    @ViewBuilder
    private var displayContent: some View {
        if viewMode == PageViewMode.blend.rawValue {
            BlendView(viewModel: viewModel)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 48)
        } else if viewMode == PageViewMode.showcase.rawValue {
            ShowcaseView(viewModel: viewModel)
                .padding(.top, 8)
                .padding(.bottom, 32)
        } else {
            GadgetsView(viewModel: viewModel)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 48)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if targetEnvironment(macCatalyst)
        ToolbarItem {
            Picker("View Mode", selection: $viewMode) {
                Label("Gadgets", systemImage: "rectangle.grid.3x2")
                    .tag(PageViewMode.gadgets.rawValue)
                    .accessibilityIdentifier("gadgets-view-button")
                Label("Showcase", systemImage: "square.grid.3x1.below.line.grid.1x2")
                    .tag(PageViewMode.showcase.rawValue)
                    .accessibilityIdentifier("showcase-view-button")
                Label("Blend", systemImage: "square.text.square")
                    .tag(PageViewMode.blend.rawValue)
                    .accessibilityIdentifier("blend-view-button")
            }
            .pickerStyle(.inline)
            .padding(.horizontal, 8)
        }
        ToolbarItem {
            Button {
                subscriptionManager.showSubscribe()
            } label: {
                Label("Add Feed", systemImage: "plus.circle")
            }
            .buttonStyle(ToolbarButtonStyle())
            .disabled(refreshManager.isRefreshing)
            .accessibilityIdentifier("add-feed-button")
        }
        ToolbarItem {
            Button {
                showingSettings = true
            } label: {
                Label("Page Settings", systemImage: "wrench")
            }
            .buttonStyle(ToolbarButtonStyle())
            .disabled(refreshManager.isRefreshing)
            .accessibilityIdentifier("page-settings-button")
        }
        ToolbarItem {
            if viewModel.refreshing {
                ProgressView().progressViewStyle(ToolbarProgressStyle())
            } else {
                Button {
                    refreshManager.refresh(page: viewModel.page)
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(ToolbarButtonStyle())
                .disabled(refreshManager.isRefreshing)
                .keyboardShortcut("r", modifiers: [.command])
                .accessibilityIdentifier("page-refresh-button")
            }
        }
        #else
        ToolbarItem {
            Menu {
                Button {
                    subscriptionManager.showSubscribe()
                } label: {
                    Label("Add Feed", systemImage: "plus.circle")
                }.accessibilityIdentifier("add-feed-button")

                Button {
                    showingSettings = true
                } label: {
                    Label("Page Settings", systemImage: "wrench")
                }.accessibilityIdentifier("page-settings-button")

                if viewMode != PageViewMode.gadgets.rawValue {
                    Button {
                        viewMode = PageViewMode.gadgets.rawValue
                    } label: {
                        Label("Gadgets View", systemImage: "rectangle.grid.3x2")
                    }.accessibilityIdentifier("gadgets-view-button")
                }

                if viewMode != PageViewMode.showcase.rawValue {
                    Button {
                        viewMode = PageViewMode.showcase.rawValue
                    } label: {
                        Label("Showcase View", systemImage: "square.grid.3x1.below.line.grid.1x2")
                    }.accessibilityIdentifier("showcase-view-button")
                }

                if viewMode != PageViewMode.blend.rawValue {
                    Button {
                        viewMode = PageViewMode.blend.rawValue
                    } label: {
                        Label("Blend View", systemImage: "square.text.square")
                    }.accessibilityIdentifier("blend-view-button")
                }
            } label: {
                Label("Page Menu", systemImage: "ellipsis.circle")
            }
            .buttonStyle(ToolbarButtonStyle())
            .disabled(refreshManager.isRefreshing)
            .accessibilityIdentifier("page-menu")
            .accessibilityElement(children: .contain)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.refreshing {
                ProgressView().progressViewStyle(ToolbarProgressStyle())
            } else {
                Button {
                    refreshManager.refresh(page: viewModel.page)
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(ToolbarButtonStyle())
                .disabled(refreshManager.isRefreshing)
                .keyboardShortcut("r", modifiers: [.command])
                .accessibilityIdentifier("page-refresh-button")
            }
        }
        #endif
    }
}
