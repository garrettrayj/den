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

    @AppStorage("PageLayout_NoID") private var pageLayout = PageLayout.gadgets

    var body: some View {
        if page.feedsArray.isEmpty {
            NoFeeds(page: page)
        } else {
            WithItems(scopeObject: page) { items in
                VStack {
                    switch pageLayout {
                    case .deck:
                        DeckLayout(
                            page: page,
                            profile: profile,
                            hideRead: hideRead,
                            items: items.visibilityFiltered(hideRead ? false : nil)
                        )
                    case .blend:
                        BlendLayout(
                            page: page,
                            profile: profile,
                            hideRead: hideRead,
                            items: items.visibilityFiltered(hideRead ? false : nil)
                        )
                    case .showcase:
                        ShowcaseLayout(
                            page: page,
                            profile: profile,
                            hideRead: hideRead,
                            items: items.visibilityFiltered(hideRead ? false : nil)
                        )
                    case .gadgets:
                        GadgetLayout(
                            page: page,
                            profile: profile,
                            hideRead: hideRead,
                            items: items.visibilityFiltered(hideRead ? false : nil)
                        )
                    }
                }
                .modifier(URLDropTargetModifier(page: page))
                .toolbar {
                    #if targetEnvironment(macCatalyst)
                    ToolbarItem(placement: .secondaryAction) {
                        PageLayoutPicker(pageLayout: $pageLayout).pickerStyle(.segmented)
                    }
                    ToolbarItem(placement: .primaryAction) {
                        AddFeedButton(page: page)
                    }
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink(value: DetailPanel.pageSettings(page)) {
                            Label("Page Settings", systemImage: "wrench")
                        }
                        .buttonStyle(ToolbarButtonStyle())
                        .accessibilityIdentifier("page-settings-button")
                    }
                    #else
                    ToolbarItem {
                        Menu {
                            PageLayoutPicker(pageLayout: $pageLayout)
                            AddFeedButton(page: page)
                            NavigationLink(value: DetailPanel.pageSettings(page)) {
                                Label("Page Settings", systemImage: "wrench")
                            }
                            .accessibilityIdentifier("page-settings-button")
                        } label: {
                            Label("Page Menu", systemImage: "ellipsis.circle")
                        }
                        .accessibilityIdentifier("page-menu")
                    }
                    #endif

                    PageBottomBar(
                        page: page,
                        profile: profile,
                        hideRead: $hideRead,
                        items: items
                    )
                }
                .navigationTitle(page.displayName)
            }
        }
    }

    init(
        page: Page,
        profile: Profile,
        hideRead: Binding<Bool>
    ) {
        _hideRead = hideRead
        _pageLayout = AppStorage(
            wrappedValue: PageLayout.gadgets,
            "PageLayout_\(page.id?.uuidString ?? "NoID")"
        )

        self.page = page
        self.profile = profile
    }
}
