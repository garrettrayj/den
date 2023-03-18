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

    @AppStorage("PageLayout_NA") private var pageLayout = PageLayout.gadgets
    @AppStorage("PagePreviewStyle_NA") private var previewStyle = PreviewStyle.compressed

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
        ) { items in
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
                            DeckLayoutView(
                                page: page,
                                previewStyle: $previewStyle,
                                items: items,
                                pageGeometry: geometry
                            )
                        case .blend:
                            BlendLayoutView(previewStyle: $previewStyle, items: items, width: geometry.size.width)
                        case .showcase:
                            ShowcaseLayoutView(
                                page: page,
                                previewStyle: $previewStyle,
                                items: items,
                                width: geometry.size.width
                            )
                        case .gadgets:
                            GadgetLayoutView(
                                page: page,
                                previewStyle: $previewStyle,
                                items: items,
                                width: geometry.size.width
                            )
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
        }
    }
    
    init(
        page: Page,
        profile: Profile,
        hideRead: Binding<Bool>,
        refreshing: Binding<Bool>
    ) {
        self.page = page
        self.profile = profile
        
        _hideRead = hideRead
        _refreshing = refreshing
        
        _pageLayout = AppStorage(
            wrappedValue: PageLayout.gadgets,
            "PageLayout_\(page.id?.uuidString ?? "NA")"
        )
        _previewStyle = AppStorage(
            wrappedValue: PreviewStyle.compressed,
            "PagePreviewStyle_\(page.id?.uuidString ?? "NA")"
        )
    }
}
