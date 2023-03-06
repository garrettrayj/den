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
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    @SceneStorage("PageLayout") private var pageLayout = PageLayout.gadgets
    @SceneStorage("PagePreviewStyle") private var previewStyle = PreviewStyle.compressed

    private var sortDescriptors: [NSSortDescriptor] {
        if pageLayout == .blend {
            return [NSSortDescriptor(keyPath: \Item.published, ascending: false)]
        }

        return [
            NSSortDescriptor(keyPath: \Item.feedData?.id, ascending: false),
            NSSortDescriptor(keyPath: \Item.published, ascending: false)
        ]
    }

    var body: some View {
        WithItems(
            scopeObject: page,
            sortDescriptors: sortDescriptors,
            readFilter: hideRead ? false : nil
        ) { _, items in
            GeometryReader { geometry in
                VStack {
                    if page.feedsArray.isEmpty {
                        NoFeedsView(page: page)
                    } else if items.isEmpty && pageLayout == .blend {
                        if hideRead == true {
                            AllReadSplashNoteView()
                        } else {
                            SplashNoteView(title: "No Items", note: "Refresh to get content.")
                        }
                    } else {
                        switch pageLayout {
                        case .deck:
                            ScrollView(.horizontal) {
                                LazyHStack(alignment: .top, spacing: 0) {
                                    ForEach(page.feedsArray) { feed in
                                        DeckColumnView(
                                            feed: feed,
                                            isFirst: page.feedsArray.first == feed,
                                            isLast: page.feedsArray.last == feed,
                                            items: items.forFeed(feed: feed),
                                            previewStyle: previewStyle
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
                                        if previewStyle == .compressed {
                                            FeedItemCompressedView(item: item)
                                        } else {
                                            FeedItemExpandedView(item: item)
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
                                            previewStyle: previewStyle,
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
                                        previewStyle: previewStyle
                                    )
                                }.modifier(MainBoardModifier())
                            }.id("\(page.id?.uuidString ?? "na")_\(pageLayout)")
                        }
                    }
                }
                .modifier(URLDropTargetModifier(page: page))
                .navigationTitle(page.displayName)
                .toolbar {
                    #if targetEnvironment(macCatalyst)
                    ToolbarItemGroup {
                        PreviewStyleButtonView(previewStyle: $previewStyle)
                        PageLayoutPickerView(pageLayout: $pageLayout).pickerStyle(.segmented)
                        NavigationLink(value: DetailPanel.pageSettings(page)) {
                            Label("Page Settings", systemImage: "wrench")
                        }
                        .buttonStyle(ToolbarButtonStyle())
                        .accessibilityIdentifier("page-settings-button")
                    }
                    #else
                    ToolbarItem {
                        Menu {
                            PreviewStyleButtonView(previewStyle: $previewStyle)
                            PageLayoutPickerView(pageLayout: $pageLayout)
                            NavigationLink(value: DetailPanel.pageSettings(page)) {
                                Label("Page Settings", systemImage: "wrench")
                            }
                            .buttonStyle(ToolbarButtonStyle())
                            .accessibilityIdentifier("page-settings-button")
                        } label: {
                            Label("Page Menu", systemImage: "ellipsis.circle")
                        }
                    }
                    #endif

                    ToolbarItemGroup(placement: .bottomBar) {
                        PageBottomBarView(
                            page: page,
                            profile: profile,
                            refreshing: $refreshing,
                            hideRead: $hideRead
                        )
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}
