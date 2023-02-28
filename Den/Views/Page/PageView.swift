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
    @ObservedObject var page: Page

    @Binding var hideRead: Bool

    @SceneStorage("PageLayout") private var pageLayout = PageLayout.gadgets.rawValue
    @SceneStorage("PagePreviewStyle") private var previewStyle = PreviewStyle.compact.rawValue

    private var wrappedPageLayout: PageLayout {
        return PageLayout(rawValue: pageLayout) ?? PageLayout.gadgets
    }

    private var wrappedPreviewStyle: PreviewStyle {
        return PreviewStyle(rawValue: previewStyle) ?? PreviewStyle.compact
    }

    private var sortDescriptors: [NSSortDescriptor] {
        if wrappedPageLayout == .blend {
            return [NSSortDescriptor(keyPath: \Item.published, ascending: false)]
        }

        return [
            NSSortDescriptor(keyPath: \Item.feedData, ascending: false),
            NSSortDescriptor(keyPath: \Item.published, ascending: false)
        ]
    }

    var body: some View {
        WithItems(
            scopeObject: page,
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.published, ascending: false)],
            readFilter: hideRead ? false : nil
        ) { _, items in
            GeometryReader { geometry in
                VStack {
                    if page.feedsArray.isEmpty {
                        NoFeedsView(page: page)
                    } else if items.isEmpty && wrappedPageLayout == .blend {
                        if hideRead == true {
                            AllReadSplashNoteView()
                        } else {
                            SplashNoteView(title: "No Items", note: "Refresh to get content.")
                        }
                    } else {
                        switch wrappedPageLayout {
                        case .deck:
                            ScrollView(.horizontal) {
                                LazyHStack(alignment: .top, spacing: 0) {
                                    ForEach(page.feedsArray) { feed in
                                        DeckColumnView(
                                            feed: feed,
                                            isFirst: page.feedsArray.first == feed,
                                            isLast: page.feedsArray.last == feed,
                                            items: items.forFeed(feed: feed),
                                            previewStyle: wrappedPreviewStyle
                                        )
                                    }
                                }
                            }
                            .id("\(page.id?.uuidString ?? "na")_\(pageLayout)")
                            .navigationBarTitleDisplayMode(.inline)
                        case .blend:
                            ScrollView(.vertical) {
                                BoardView(width: geometry.size.width, list: Array(items)) { item in
                                    ItemActionView(item: item) {
                                        if wrappedPreviewStyle == .compact {
                                            FeedItemCompactView(item: item)
                                        } else {
                                            FeedItemTeaserView(item: item)
                                        }
                                    }
                                }.modifier(MainBoardModifier())
                            }.id("\(page.id?.uuidString ?? "na")_\(pageLayout)")
                        case .showcase:
                            ScrollView(.vertical) {
                                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                                    ForEach(page.feedsArray) { feed in
                                        ShowcaseSectionView(
                                            feed: feed,
                                            items: items.forFeed(feed: feed),
                                            previewStyle: wrappedPreviewStyle,
                                            width: geometry.size.width
                                        )
                                    }
                                }
                                Spacer()
                            }.id("\(page.id?.uuidString ?? "na")_\(pageLayout)")
                        case .gadgets:
                            ScrollView(.vertical) {
                                BoardView(width: geometry.size.width, list: page.feedsArray) { feed in
                                    GadgetView(
                                        feed: feed,
                                        items: items.forFeed(feed: feed),
                                        previewStyle: wrappedPreviewStyle
                                    )
                                }.modifier(MainBoardModifier())
                            }.id("\(page.id?.uuidString ?? "na")_\(pageLayout)")
                        }
                    }
                }
                .modifier(URLDropTargetModifier(page: page))
                .navigationTitle(page.displayName)
                .toolbar {
                    ToolbarItemGroup {
                        if geometry.size.width > 460 {
                            PreviewStylePickerView(previewStyle: $previewStyle).pickerStyle(.segmented)
                            Divider()
                            PageLayoutPickerView(pageLayout: $pageLayout).pickerStyle(.segmented)
                        } else {
                            PreviewStylePickerView(previewStyle: $previewStyle)
                            PageLayoutPickerView(pageLayout: $pageLayout)
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
                            hideRead: $hideRead,
                            visibleItems: items
                        )
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}
