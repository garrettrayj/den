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
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @ObservedObject var viewModel: PageViewModel

    @State var showingSettings: Bool = false

    @AppStorage("pageViewMode_na") var viewMode = 0

    init(viewModel: PageViewModel) {
        self.viewModel = viewModel

        _viewMode = AppStorage(
            wrappedValue: PageViewMode.gadgets.rawValue,
            "pageViewMode_\(viewModel.page.id?.uuidString ?? "na")"
        )
    }

    var body: some View {
        Group {
            if viewModel.page.managedObjectContext == nil {
                StatusBoxView(message: "Page Deleted", symbol: "slash.circle").navigationBarHidden(true)
            } else if viewModel.page.feedsArray.count == 0 {
                StatusBoxView(message: "Page Empty")
            } else {
                if viewMode == PageViewMode.blend.rawValue {
                    BlendView(viewModel: viewModel)
                } else if viewMode == PageViewMode.showcase.rawValue {
                    ShowcaseView(viewModel: viewModel)
                } else {
                    GadgetsView(viewModel: viewModel)
                }
            }
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
        .toolbar {
            #if targetEnvironment(macCatalyst)
            ToolbarItem {
                Picker("View Mode", selection: $viewMode) {
                    Label("Gadgets", systemImage: "square.grid.2x2")
                        .tag(PageViewMode.gadgets.rawValue)
                    Label("Showcase", systemImage: "square.grid.3x1.below.line.grid.1x2")
                        .tag(PageViewMode.showcase.rawValue)
                    Label("Blend", systemImage: "square.text.square")
                        .tag(PageViewMode.blend.rawValue)
                }
                .pickerStyle(.segmented)
                .imageScale(.small)
                .padding(.horizontal, 8)
            }
            ToolbarItem {
                Button {
                    subscriptionManager.showSubscribe()
                } label: {
                    Label("Add Source", systemImage: "plus.circle").labelStyle(ToolbarLabelStyle())
                }
                .disabled(refreshManager.isRefreshing)
            }
            ToolbarItem {
                Button {
                    showingSettings = true
                } label: {
                    Label("Page Settings", systemImage: "wrench").labelStyle(ToolbarLabelStyle())
                }
                .disabled(refreshManager.isRefreshing)
            }
            ToolbarItem {
                Button {
                    refreshManager.refresh(page: viewModel.page)
                } label: {
                    if viewModel.refreshing {
                        ProgressView().progressViewStyle(ToolbarProgressStyle())
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise").labelStyle(ToolbarLabelStyle())
                    }
                }
                .disabled(refreshManager.isRefreshing)
                .keyboardShortcut("r", modifiers: [.command])
            }
            #else
            ToolbarItem {
                Menu {
                    Button {
                        subscriptionManager.showSubscribe()
                    } label: {
                        Label("Add Source", systemImage: "plus.circle")
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
                            Label("Gadgets View", systemImage: "square.grid.2x2")
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
                .keyboardShortcut("r", modifiers: [.command])
            }
            #endif
        }
        .onAppear {
            subscriptionManager.activePage = viewModel.page
        }
    }
}
