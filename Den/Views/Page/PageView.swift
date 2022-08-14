//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct PageView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var syncManager: SyncManager

    @ObservedObject var page: Page

    @State private var unreadCount: Int
    @State private var showingSettings: Bool = false

    @Binding var refreshing: Bool

    @AppStorage("pageViewMode_na") var viewMode = 0
    @AppStorage("hideRead") var hideRead = false

    enum ContentViewMode: Int {
        case gadgets  = 0
        case showcase = 1
        case blend = 2
    }

    init(page: Page, unreadCount: Int, refreshing: Binding<Bool>) {
        self.page = page
        self.unreadCount = unreadCount

        _refreshing = refreshing

        _viewMode = AppStorage(
            wrappedValue: ContentViewMode.gadgets.rawValue,
            "pageViewMode_\(page.id?.uuidString ?? "na")"
        )
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
                if viewMode == ContentViewMode.blend.rawValue {
                    BlendView(page: page, hideRead: $hideRead, refreshing: $refreshing, frameSize: geometry.size)
                } else if viewMode == ContentViewMode.showcase.rawValue {
                    ShowcaseView(page: page, hideRead: $hideRead, refreshing: $refreshing, frameSize: geometry.size)
                } else {
                    GadgetsView(page: page, hideRead: $hideRead, refreshing: $refreshing, frameSize: geometry.size)
                }
            }
        }
        .onChange(of: viewMode, perform: { _ in
            self.page.objectWillChange.send()
        })
        .onAppear { subscriptionManager.activePage = page }
        .onReceive(
            NotificationCenter.default.publisher(for: .itemStatus, object: nil)
        ) { notification in
            guard
                let pageObjectID = notification.userInfo?["pageObjectID"] as? NSManagedObjectID,
                pageObjectID == page.objectID,
                let read = notification.userInfo?["read"] as? Bool
            else {
                return
            }
            unreadCount += read ? -1 : 1
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .pageRefreshed, object: page.objectID)
        ) { _ in
            unreadCount = page.previewItems.unread().count
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
            viewModePicker
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
                    viewModePicker

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
            unreadCount: $unreadCount,
            hideRead: $hideRead,
            refreshing: $refreshing,
            centerLabel: Text("\(unreadCount) Unread")
        ) {
            withAnimation {
                syncManager.toggleReadUnread(items: page.previewItems)
                page.objectWillChange.send()
            }
        }
    }

    private var viewModePicker: some View {
        Picker("View Mode", selection: $viewMode) {
            Label("Gadgets", systemImage: "rectangle.grid.3x2")
                .tag(ContentViewMode.gadgets.rawValue)
                .accessibilityIdentifier("gadgets-view-button")
            Label("Showcase", systemImage: "square.grid.3x1.below.line.grid.1x2")
                .tag(ContentViewMode.showcase.rawValue)
                .accessibilityIdentifier("showcase-view-button")
            Label("Blend", systemImage: "square.text.square")
                .tag(ContentViewMode.blend.rawValue)
                .accessibilityIdentifier("page-timeline-view-button")
        }
    }
}
