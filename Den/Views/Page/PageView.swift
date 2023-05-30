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
        if page.managedObjectContext == nil {
            SplashNote(title: Text("Page Deleted", comment: "Object removed message"))
        } else if page.feedsArray.isEmpty {
            NoFeeds(page: page)
        } else {
            WithItems(scopeObject: page) { items in
                ZStack {
                    switch pageLayout {
                    case .deck:
                        DeckLayout(
                            page: page,
                            profile: profile,
                            hideRead: hideRead,
                            items: items
                        )
                    case .blend:
                        BlendLayout(
                            page: page,
                            profile: profile,
                            hideRead: hideRead,
                            items: items
                        )
                    case .showcase:
                        ShowcaseLayout(
                            page: page,
                            profile: profile,
                            hideRead: hideRead,
                            items: items
                        )
                    case .gadgets:
                        GadgetLayout(
                            page: page,
                            profile: profile,
                            hideRead: hideRead,
                            items: items
                        )
                    }
                }
                .modifier(URLDropTargetModifier(page: page))
                .toolbar {
                    #if targetEnvironment(macCatalyst)
                    ToolbarItem {
                        AddFeedButton(page: page)
                    }
                    ToolbarItem {
                        NavigationLink(value: SubDetailPanel.pageSettings(page)) {
                            Label {
                                Text("Page Settings", comment: "Navigation bar button label")
                            } icon: {
                                Image(systemName: "wrench")
                            }
                        }
                        .buttonStyle(ToolbarButtonStyle())
                        .accessibilityIdentifier("page-settings-button")
                    }
                    ToolbarItem(placement: .secondaryAction) {
                        PageLayoutPicker(pageLayout: $pageLayout).pickerStyle(.segmented)
                    }
                    #else
                    ToolbarItem {
                        Menu {
                            PageLayoutPicker(pageLayout: $pageLayout)
                            AddFeedButton(page: page)
                            NavigationLink(value: SubDetailPanel.pageSettings(page)) {
                                Label {
                                    Text("Page Settings", comment: "Button label")
                                } icon: {
                                    Image(systemName: "wrench")
                                }
                            }
                            .accessibilityIdentifier("page-settings-button")
                        } label: {
                            Label {
                                Text("Page Menu", comment: "Menu label")
                            } icon: {
                                Image(systemName: "ellipsis.circle")
                            }
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
                .navigationTitle(page.nameText)
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
