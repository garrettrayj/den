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
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var crashManager: CrashManager
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
                ).toolbar { toolbarContent }
            } else {
                GeometryReader { geometry in
                    if viewMode == PageViewMode.blend.rawValue {
                        BlendView(page: viewModel.page, frameSize: geometry.size)
                    } else if viewMode == PageViewMode.showcase.rawValue {
                        ShowcaseView(page: viewModel.page, frameSize: geometry.size)
                    } else {
                        GadgetsView(page: viewModel.page, frameSize: geometry.size)
                    }
                }.toolbar { toolbarContent }
            }
        }
        .onAppear {
            subscriptionManager.activePage = viewModel.page
        }
        .onChange(of: viewMode, perform: { _ in
            viewModel.objectWillChange.send()
        })
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .background(
            Group {
                NavigationLink(
                    destination: PageSettingsView(viewModel: PageSettingsViewModel(
                        viewContext: viewContext,
                        crashManager: crashManager,
                        page: viewModel.page
                    )),
                    isActive: $showingSettings
                ) {
                    EmptyView()
                }
            }
        )
        .navigationTitle(viewModel.page.displayName)
        .navigationBarTitleDisplayMode(.large)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if targetEnvironment(macCatalyst)
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
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
                .disabled(viewModel.refreshing)

                Button {
                    subscriptionManager.showSubscribe()
                } label: {
                    Label("Add Feed", systemImage: "plus.circle")
                }
                .accessibilityIdentifier("add-feed-button")
                .disabled(viewModel.refreshing)

                if viewModel.refreshing {
                    ProgressView()
                        .progressViewStyle(ToolbarProgressStyle())
                } else {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Page Settings", systemImage: "wrench")
                    }
                    .accessibilityIdentifier("page-settings-button")
                    .disabled(viewModel.refreshing)
                }
            }
        }
        #else
        ToolbarItem {
            if viewModel.refreshing {
                ProgressView()
                    .progressViewStyle(ToolbarProgressStyle())
            } else {
                Menu {
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
                } label: {
                    Label("Page Menu", systemImage: "ellipsis.circle").font(.body.weight(.medium))
                }
                .accessibilityIdentifier("page-menu")
            }
        }
        #endif
    }
}
