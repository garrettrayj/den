//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageView: View {
    enum PageViewMode: Int {
        case gadgets  = 0
        case showcase = 1
        case blend    = 2
    }

    @ObservedObject var page: Page

    @Binding var hideRead: Bool

    @SceneStorage("PageViewMode") private var sceneViewMode = PageViewMode.gadgets.rawValue
    
    private var viewMode: PageViewMode {
        return PageViewMode(rawValue: sceneViewMode) ?? PageViewMode.gadgets
    }

    var body: some View {
        GeometryReader { geometry in
            if page.feedsArray.isEmpty {
                StatusBoxView(
                    message: Text("Page Empty"),
                    caption: Text("""
                    To add feeds tap \(Image(systemName: "plus.circle")), \n\
                    open syndication links, \n\
                    or drag and drop URLs.
                    """),
                    symbol: "questionmark.folder"
                )
            } else if page.previewItems.isEmpty  && viewMode == PageViewMode.blend {
                StatusBoxView(
                    message: Text("No Items"),
                    symbol: "questionmark.folder"
                )
            } else if page.visibleItems(hideRead).isEmpty  && viewMode == PageViewMode.blend {
                AllReadStatusView(hiddenItemCount: page.previewItems.read().count)
            } else {
                ScrollView {
                    switch viewMode {
                    case .blend:
                        BoardView(width: geometry.size.width, list: page.visibleItems(hideRead)) { item in
                            FeedItemPreviewView(item: item)
                        }
                    case .showcase:
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                            ForEach(page.feedsArray) { feed in
                                ShowcaseSectionView(feed: feed, hideRead: $hideRead, width: geometry.size.width)
                            }
                        }
                    case .gadgets:
                        BoardView(width: geometry.size.width, list: page.feedsArray) { feed in
                            GadgetView(feed: feed, hideRead: $hideRead)
                        }
                    }
                }.id("\(page.id?.uuidString ?? "na")_\(sceneViewMode)")
            }
        }
        .modifier(URLDropTargetModifier(page: page))
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(page.displayName)
        .toolbar {
            #if targetEnvironment(macCatalyst)
            ToolbarItemGroup(placement: .navigationBarTrailing) {
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
                        Label("Add Feed", systemImage: "plus.circle")
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
                    viewMode: $sceneViewMode,
                    hideRead: $hideRead
                )
            }
        }
    }

    private var viewModePicker: some View {
        Picker("View Mode", selection: $sceneViewMode) {
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
    }
}
