//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI
import UniformTypeIdentifiers

struct PageView: View {
    @ObservedObject var page: Page

    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    @AppStorage("pageViewMode_na") private var viewMode = 0

    enum PageViewMode: Int {
        case gadgets  = 0
        case showcase = 1
        case blend = 2
    }

    init(page: Page, hideRead: Binding<Bool>, refreshing: Binding<Bool>) {
        self.page = page
        _hideRead = hideRead
        _refreshing = refreshing
        _viewMode = AppStorage(
            wrappedValue: PageViewMode.gadgets.rawValue,
            "pageViewMode_\(page.id?.uuidString ?? "na")"
        )
    }

    var body: some View {
        GeometryReader { geometry in
            if page.managedObjectContext == nil {
                StatusBoxView(message: Text("Page Deleted"), symbol: "slash.circle")
                    .toolbar {
                        EmptyView()
                    }
            } else if page.feedsArray.isEmpty {
                #if targetEnvironment(macCatalyst)
                StatusBoxView(
                    message: Text("Page Empty"),
                    caption: Text("""
                    To add feeds tap \(Image(systemName: "plus.circle")), \
                    open syndication links, \
                    or drag-and-drop URLs.
                    """),
                    symbol: "questionmark.folder"
                )
                #else
                StatusBoxView(
                    message: Text("Page Empty"),
                    caption: Text("""
                    To add feeds tap \(Image(systemName: "ellipsis.circle")) \
                    then \(Image(systemName: "plus.circle")), \
                    open syndication links, \
                    or drag-and-drop URLs.
                    """),
                    symbol: "questionmark.folder"
                )
                #endif
            } else if page.previewItems.isEmpty  && viewMode == PageViewMode.blend.rawValue {
                StatusBoxView(
                    message: Text("No Items"),
                    symbol: "questionmark.folder"
                )
            } else {
                if viewMode == PageViewMode.blend.rawValue {
                    BlendView(page: page, hideRead: $hideRead, frameSize: geometry.size)
                } else if viewMode == PageViewMode.showcase.rawValue {
                    ShowcaseView(page: page, hideRead: $hideRead, frameSize: geometry.size)
                } else {
                    GadgetsView(page: page, hideRead: $hideRead, frameSize: geometry.size)
                }
            }
        }
        .onChange(of: viewMode, perform: { _ in
            page.objectWillChange.send()
        })
        .modifier(URLDropTargetModifier(page: page))
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(page.displayName)
        .navigationDestination(for: PagePanel.self, destination: { pagePanel in
            switch pagePanel {
            case .pageSettings(let page):
                PageSettingsView(page: page)
            }
        })
        .toolbar {
            #if targetEnvironment(macCatalyst)
            ToolbarItemGroup {
                viewModePicker
                    .pickerStyle(.segmented)
                    .padding(8)
                    .disabled(refreshing)
                
                Button {
                    SubscriptionUtility.showSubscribe(page: page)
                } label: {
                    Label("Add Feed", systemImage: "plus.circle")
                }
                .buttonStyle(ToolbarButtonStyle())
                .accessibilityIdentifier("add-feed-button")
                .disabled(refreshing)
                
                NavigationLink(value: PagePanel.pageSettings(page)) {
                    Label("Page Settings", systemImage: "wrench")
                }
                .buttonStyle(ToolbarButtonStyle())
                .accessibilityIdentifier("page-settings-button")
                .disabled(refreshing)
            }
            #else
            ToolbarItem {
                Menu {
                    viewModePicker

                    Button {
                        SubscriptionUtility.showSubscribe(page: page)
                    } label: {
                        Label("Add Feed", systemImage: "plus.circle")
                    }
                    .accessibilityIdentifier("add-feed-button")

                    NavigationLink(value: PagePanel.pageSettings(page)) {
                        Label("Page Settings", systemImage: "wrench")
                    }
                    .accessibilityIdentifier("page-settings-button")
                } label: {
                    Label("Page Menu", systemImage: "ellipsis.circle")
                        .frame(height: 44, alignment: .center)
                        .padding(.horizontal, 8)
                        .background(Color.clear)
                        .padding(.trailing, -8)
                }
                .disabled(refreshing)
                .accessibilityIdentifier("page-menu")
            }
            #endif
            
            ToolbarItemGroup(placement: .bottomBar) {
                PageBottomBarView(
                    page: page,
                    hideRead: $hideRead,
                    refreshing: $refreshing,
                    unreadCount: page.previewItems.unread().count
                ).id(page.id)
            }
        }
    }

    private var viewModePicker: some View {
        Picker("View Mode", selection: $viewMode) {
            Label("Gadgets", systemImage: "rectangle.grid.3x2")
                .tag(PageViewMode.gadgets.rawValue)
                .accessibilityIdentifier("gadgets-view-button")
            Label("Showcase", systemImage: "square.grid.3x1.below.line.grid.1x2")
                .tag(PageViewMode.showcase.rawValue)
                .accessibilityIdentifier("showcase-view-button")
            Label("Blend", systemImage: "square.text.square")
                .tag(PageViewMode.blend.rawValue)
                .accessibilityIdentifier("page-timeline-view-button")
        }
    }
}
