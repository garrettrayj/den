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
    
    @AppStorage<Int> var viewMode: Int

    enum PageViewMode: Int {
        case gadgets  = 0
        case showcase = 1
        case blend = 2
    }

    var body: some View {
        Group {
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
                        BlendView(page: page, hideRead: $hideRead, frameSize: geometry.size)
                    } else if viewMode == PageViewMode.showcase.rawValue {
                        ShowcaseView(page: page, hideRead: $hideRead, frameSize: geometry.size)
                    } else {
                        GadgetsView(page: page, hideRead: $hideRead, frameSize: geometry.size)
                    }
                }
            }
        }
        .modifier(URLDropTargetModifier(page: page))
        .background(Color(UIColor.systemGroupedBackground))
        .toolbar {
            #if targetEnvironment(macCatalyst)
            ToolbarItemGroup(placement: .navigationBarLeading) {
                viewModePicker
                    .pickerStyle(.segmented)
                    .padding(8)
                
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
        .navigationTitle(page.displayName)
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
        .onChange(of: viewMode) { _ in
            page.objectWillChange.send()
        }
    }
}
