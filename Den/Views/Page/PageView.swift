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
    
    @SceneStorage("PageViewMode_Default") private var viewMode = 0

    enum PageViewMode: Int {
        case gadgets  = 0
        case showcase = 1
        case blend = 2
    }

    init(page: Page, hideRead: Binding<Bool>) {
        _page = ObservedObject(wrappedValue: page)
        _hideRead = hideRead
        _viewMode = SceneStorage(
            wrappedValue: PageViewMode.gadgets.rawValue,
            "PageViewMode_\(page.id?.uuidString ?? "Default")"
        )
    }

    var body: some View {
        GeometryReader { geometry in
            if page.feedsArray.isEmpty {
                StatusBoxView(
                    message: Text("Page Empty"),
                    caption: Text("""
                    To add feeds tap \(Image(systemName: "plus")), \n\
                    open syndication links, \n\
                    or drag and drop URLs.
                    """),
                    symbol: "questionmark.folder"
                )
            } else if page.previewItems.isEmpty  && viewMode == PageViewMode.blend.rawValue {
                StatusBoxView(
                    message: Text("No Items"),
                    symbol: "questionmark.folder"
                )
            } else {
                if viewMode == PageViewMode.blend.rawValue {
                    BlendView(page: page, hideRead: $hideRead, frameSize: geometry.size).id(page.id)
                } else if viewMode == PageViewMode.showcase.rawValue {
                    ShowcaseView(page: page, hideRead: $hideRead, frameSize: geometry.size).id(page.id)
                } else {
                    GadgetsView(page: page, hideRead: $hideRead, frameSize: geometry.size).id(page.id)
                }
            }
        }
        .onChange(of: viewMode, perform: { _ in
            page.objectWillChange.send()
        })
        .modifier(URLDropTargetModifier(page: page))
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(page.displayName)
        .toolbar {
            #if targetEnvironment(macCatalyst)
            ToolbarItem(placement: .navigation) {
                viewModePicker
                    .pickerStyle(.segmented)
                    .padding(8)
            }
            ToolbarItem(placement: .navigation) {
                NavigationLink(value: DetailPanel.pageSettings(page)) {
                    Label("Page Settings", systemImage: "wrench")
                }
                .buttonStyle(ToolbarButtonStyle())
                .accessibilityIdentifier("page-settings-button")
            }
            #else
            ToolbarItem {
                Menu {
                    viewModePicker
                    
                    Button {
                        SubscriptionUtility.showSubscribe(page: page)
                    } label: {
                        Label("Add Feed", systemImage: "plus")
                    }
                    .accessibilityIdentifier("add-feed-button")
                    
                    NavigationLink(value: DetailPanel.pageSettings(page)) {
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
                .accessibilityIdentifier("page-menu")
            }
            #endif
            
            ToolbarItemGroup(placement: .bottomBar) {
                PageBottomBarView(
                    page: page,
                    hideRead: $hideRead,
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
