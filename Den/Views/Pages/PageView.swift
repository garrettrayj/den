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
    Use feed links \
    or click \(Image(systemName: "plus.circle")) to add feeds
    """)
    #else
    let emptyCaption = Text("""
    Use feed links \
    or tap \(Image(systemName: "ellipsis.circle")) then “Add Feed \(Image(systemName: "plus.circle"))” \
    to add feeds
    """)
    #endif

    var body: some View {
        Group {
            if viewModel.page.managedObjectContext == nil {
                StatusBoxView(message: Text("Page Deleted"), symbol: "slash.circle").navigationBarHidden(true)
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
                    if viewMode == PageViewMode.blend.rawValue {
                        BlendView(viewModel: viewModel)
                    } else if viewMode == PageViewMode.showcase.rawValue {
                        ShowcaseView(viewModel: viewModel)
                    } else {
                        GadgetsView(viewModel: viewModel)
                    }
                }
                #else
                RefreshableScrollView(
                    onRefresh: { done in
                        refreshManager.refresh(page: viewModel.page)
                        done()
                    },
                    content: {
                        if viewMode == PageViewMode.blend.rawValue {
                            BlendView(viewModel: viewModel)
                        } else if viewMode == PageViewMode.showcase.rawValue {
                            ShowcaseView(viewModel: viewModel)
                        } else {
                            GadgetsView(viewModel: viewModel)
                        }
                    }
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
            }
        )
        .navigationTitle(viewModel.page.displayName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            #if targetEnvironment(macCatalyst)
            ToolbarItem {
                Picker("View Mode", selection: $viewMode) {
                    Label("Gadgets", systemImage: "rectangle.grid.3x2")
                        .tag(PageViewMode.gadgets.rawValue)
                    Label("Showcase", systemImage: "square.grid.3x1.below.line.grid.1x2")
                        .tag(PageViewMode.showcase.rawValue)
                    Label("Blend", systemImage: "square.text.square")
                        .tag(PageViewMode.blend.rawValue)
                }
                .pickerStyle(.inline)
                .padding(.horizontal, 8)
            }
            ToolbarItem {
                Button {
                    subscriptionManager.showSubscribe(for: viewModel.page)
                } label: {
                    Label("Add Feed", systemImage: "plus.circle")
                }
                .buttonStyle(ToolbarButtonStyle())
                .disabled(refreshManager.isRefreshing)
            }
            ToolbarItem {
                Button {
                    showingSettings = true
                } label: {
                    Label("Page Settings", systemImage: "wrench")
                }
                .buttonStyle(ToolbarButtonStyle())
                .disabled(refreshManager.isRefreshing)
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
                }
            }
            #else
            ToolbarItem {
                Menu {
                    Button {
                        subscriptionManager.showSubscribe(for: viewModel.page)
                    } label: {
                        Label("Add Feed", systemImage: "plus.circle")
                    }

                    Button {
                        showingSettings = true
                    } label: {
                        Label("Page Settings", systemImage: "wrench")
                    }

                    if viewMode != PageViewMode.gadgets.rawValue {
                        Button {
                            viewMode = PageViewMode.gadgets.rawValue
                        } label: {
                            Label("Gadgets View", systemImage: "rectangle.grid.3x2")
                        }
                    }

                    if viewMode != PageViewMode.showcase.rawValue {
                        Button {
                            viewMode = PageViewMode.showcase.rawValue
                        } label: {
                            Label("Showcase View", systemImage: "square.grid.3x1.below.line.grid.1x2")
                        }
                    }

                    if viewMode != PageViewMode.blend.rawValue {
                        Button {
                            viewMode = PageViewMode.blend.rawValue
                        } label: {
                            Label("Blend View", systemImage: "square.text.square")
                        }
                    }
                } label: {
                    Label("Page Menu", systemImage: "ellipsis.circle")
                }
                .disabled(refreshManager.isRefreshing)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    refreshManager.refresh(page: viewModel.page)
                } label: {
                    if viewModel.refreshing {
                        ProgressView().progressViewStyle(ToolbarProgressStyle())
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                .disabled(refreshManager.isRefreshing)
                .keyboardShortcut("r", modifiers: [.command])
            }
            #endif
        }
    }
}
