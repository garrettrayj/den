//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
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
            VStack {
                if page.feedsArray.isEmpty {
                    SplashNoteView(
                        title: Text("Page Empty"),
                        caption: Text("""
                        Tap \(Image(systemName: "plus.circle")), \
                        open syndication links, or drag and drop URLs to add feeds.
                        """)
                    )
                } else if page.previewItems.isEmpty  && viewMode == PageViewMode.blend {
                    SplashNoteView(
                        title: Text("No Items"),
                        caption: Text("Refresh \(Image(systemName: "arrow.clockwise")) to fetch content.")
                    )
                } else if page.visibleItems(hideRead).isEmpty  && viewMode == PageViewMode.blend {
                    AllReadSplashNoteView(hiddenItemCount: page.previewItems.read().count)
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
            .navigationTitle(page.displayName)
            .toolbar {
                ToolbarItem {
                    if geometry.size.width > 460 {
                        viewModePicker.pickerStyle(.segmented)
                    } else {
                        viewModePicker
                    }
                }

                ToolbarItem {
                    NavigationLink(value: DetailPanel.pageSettings(page)) {
                        Label("Page Settings", systemImage: "wrench")
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .accessibilityIdentifier("page-settings-button")
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    PageBottomBarView(
                        page: page,
                        viewMode: $sceneViewMode,
                        hideRead: $hideRead
                    )
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
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
        }.accessibilityIdentifier("view-mode-picker")
    }
}
