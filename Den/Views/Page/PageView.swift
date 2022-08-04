//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var linkManager: LinkManager

    @ObservedObject var page: Page

    @Binding var refreshing: Bool

    @State private var showingSettings: Bool = false

    @AppStorage("pageViewMode_na") var viewMode = 0
    @AppStorage("hideRead") var hideRead = false

    init(page: Page, refreshing: Binding<Bool>) {
        self.page = page

        _refreshing = refreshing

        _viewMode = AppStorage(
            wrappedValue: ContentViewMode.gadgets.rawValue,
            "pageViewMode_\(page.id?.uuidString ?? "na")"
        )
    }

    private var visibleItems: [Item] {
        page.limitedItemsArray.filter { item in
            hideRead ? item.read == false : true
        }
    }

    var body: some View {
        GeometryReader { geometry in
            if page.managedObjectContext == nil {
                StatusBoxView(message: Text("Page Deleted"), symbol: "slash.circle")
                    .navigationTitle("")
                    .toolbar {
                        EmptyView()
                    }
            } else if page.feedsArray.isEmpty {
                NoFeedsView()
            } else if page.previewItems.isEmpty  && viewMode == ContentViewMode.blend.rawValue {
                NoItemsView()
            } else {
                ScrollView(.vertical) {
                    Group {
                        if viewMode == ContentViewMode.blend.rawValue {
                            BlendView(page: page, hideRead: $hideRead, frameSize: geometry.size)
                        } else if viewMode == ContentViewMode.showcase.rawValue {
                            ShowcaseView(page: page, hideRead: $hideRead, frameSize: geometry.size)
                        } else {
                            GadgetsView(page: page, hideRead: $hideRead, frameSize: geometry.size)
                        }
                    }.padding(.top, 8)
                }
            }
        }
        .onAppear {
            subscriptionManager.activePage = page
        }
        .background(Color(UIColor.systemGroupedBackground))
        .background(
            Group {
                NavigationLink(
                    destination: PageSettingsView(page: page),
                    isActive: $showingSettings
                ) {
                    EmptyView()
                }
            }
        )
        .navigationTitle(page.displayName)
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
            .disabled(refreshing)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                subscriptionManager.showSubscribe()
            } label: {
                Label("Add Feed", systemImage: "plus.circle")
            }
            .accessibilityIdentifier("add-feed-button")
            .disabled(refreshing)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if refreshing {
                ProgressView()
                    .progressViewStyle(ToolbarProgressStyle())
            } else {
                Button {
                    showingSettings = true
                } label: {
                    Label("Page Settings", systemImage: "wrench")
                }
                .accessibilityIdentifier("page-settings-button")
                .disabled(refreshing)
            }
        }
        #else
        ToolbarItem {
            if refreshing {
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
            items: page.previewItems,
            disabled: refreshing,
            hideRead: $hideRead
        ) {
            linkManager.toggleReadUnread(items: page.previewItems)
            page.objectWillChange.send()
        }
    }
}
