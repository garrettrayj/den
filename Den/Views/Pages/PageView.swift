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
    case heap     = 2
}

struct PageView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscribeManager: SubscribeManager

    @ObservedObject var viewModel: PageViewModel

    @State var showingSettings: Bool = false

    @AppStorage("pageViewModel_na") var viewMode = 0

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
                ScrollView(.vertical) {
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
                    destination: PageSettingsView(viewModel: viewModel),
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
                    Label("Heap", systemImage: "square.text.square")
                        .tag(PageViewMode.heap.rawValue)
                }
                .padding(.leading)
                .padding(.trailing, 4)
                .pickerStyle(.segmented)
            }
            ToolbarItem {
                Button {
                    subscribeManager.showAddSubscription()
                } label: {
                    Label("Add Subscription", systemImage: "plus.circle")
                }.buttonStyle(NavigationBarButtonStyle())
            }
            ToolbarItem {
                Button {
                    showingSettings = true
                } label: {
                    Label("Page Settings", systemImage: "wrench")
                }.buttonStyle(NavigationBarButtonStyle())
            }
            ToolbarItem {
                Button {
                    refreshManager.refresh(page: viewModel.page)
                } label: {
                    if viewModel.refreshing {
                        ProgressView().progressViewStyle(NavigationBarProgressStyle())
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                .buttonStyle(NavigationBarButtonStyle())
                .keyboardShortcut("r", modifiers: [.command])
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

                    if viewMode != PageViewMode.heap.rawValue {
                        Button {
                            viewMode = PageViewMode.heap.rawValue
                        } label: {
                            Label("Heap View", systemImage: "square.text.square")
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
            if viewMode == PageViewMode.heap.rawValue {
                HeapView(viewModel: viewModel)
            } else if viewMode == PageViewMode.showcase.rawValue {
                ShowcaseView(viewModel: viewModel)
            } else {
                GadgetsView(viewModel: viewModel)
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
}
