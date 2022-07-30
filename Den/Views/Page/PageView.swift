//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var linkManager: LinkManager
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var viewModel: PageViewModel

    @State private var showingSettings: Bool = false

    @AppStorage("pageViewMode_na") var viewMode = 0
    @AppStorage("hideRead") var hideRead = false

    init(viewModel: PageViewModel) {
        self.viewModel = viewModel

        _viewMode = AppStorage(
            wrappedValue: ContentViewMode.gadgets.rawValue,
            "pageViewMode_\(viewModel.page.id?.uuidString ?? "na")"
        )
    }

    private var visibleItems: [Item] {
        viewModel.page.limitedItemsArray.filter { item in
            hideRead ? item.read == false : true
        }
    }

    var body: some View {
        GeometryReader { geometry in
            if viewModel.page.managedObjectContext == nil {
                StatusBoxView(message: Text("Page Deleted"), symbol: "slash.circle")
                    .navigationTitle("")
                    .toolbar {
                        EmptyView()
                    }
            } else if viewModel.page.feedsArray.isEmpty {
                NoFeedsView()
            } else if viewModel.page.previewItems.isEmpty  && viewMode == ContentViewMode.blend.rawValue {
                NoItemsView()
            } else {
                ScrollView(.vertical) {
                    Group {
                        if viewMode == ContentViewMode.blend.rawValue {
                            BlendView(page: viewModel.page, hideRead: $hideRead, frameSize: geometry.size)
                        } else if viewMode == ContentViewMode.showcase.rawValue {
                            ShowcaseView(page: viewModel.page, hideRead: $hideRead, frameSize: geometry.size)
                        } else {
                            GadgetsView(page: viewModel.page, hideRead: $hideRead, frameSize: geometry.size)
                        }
                    }.padding(.top, 8)
                }
            }
        }
        .onAppear {
            viewModel.objectWillChange.send()
            subscriptionManager.activePage = viewModel.page
        }
        .onChange(of: viewMode, perform: { _ in
            viewModel.objectWillChange.send()
        })
        .background(Color(UIColor.systemGroupedBackground))
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
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if targetEnvironment(macCatalyst)
        ToolbarItem(placement: .navigationBarTrailing) {
            Picker("View Mode", selection: $viewMode) {
                Label("Gadgets", systemImage: "rectangle.grid.3x2")
                    .tag(ContentViewMode.gadgets.rawValue)
                    .accessibilityIdentifier("gadgets-view-button")
                Label("Showcase", systemImage: "square.grid.3x1.below.line.grid.1x2")
                    .tag(ContentViewMode.showcase.rawValue)
                    .accessibilityIdentifier("showcase-view-button")
                Label("Timeline", systemImage: "calendar.day.timeline.leading")
                    .tag(ContentViewMode.blend.rawValue)
                    .accessibilityIdentifier("page-timeline-view-button")
            }
            .padding(.trailing, 8)
            .pickerStyle(.inline)
            .disabled(viewModel.refreshing)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                subscriptionManager.showSubscribe()
            } label: {
                Label("Add Feed", systemImage: "plus.circle")
            }
            .accessibilityIdentifier("add-feed-button")
            .disabled(viewModel.refreshing)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
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
                            .accessibilityIdentifier("page-gadgets-view-button")
                        Label("Showcase", systemImage: "square.grid.3x1.below.line.grid.1x2")
                            .tag(PageViewMode.showcase.rawValue)
                            .accessibilityIdentifier("page-showcase-view-button")
                        Label("Timeline", systemImage: "calendar.day.timeline.leading")
                            .tag(PageViewMode.timeline.rawValue)
                            .accessibilityIdentifier("page-timeline-view-button")
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

        ReadingToolbarContent(
            items: viewModel.page.previewItems,
            disabled: viewModel.refreshing,
            hideRead: $hideRead
        ) {
            linkManager.toggleReadUnread(page: viewModel.page)
            dispatchItemChanges()
        } filterAction: {
            withAnimation {
                hideRead.toggle()
            }
        }
    }

    private func dispatchItemChanges() {
        DispatchQueue.main.async {
            viewModel.page.previewItems.forEach { item in
                item.objectWillChange.send()
            }
            viewModel.objectWillChange.send()
        }
    }
}
