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

    @AppStorage("PageLayout_NoID") private var pageLayout = PageLayout.gadgets
    @AppStorage("PagePreviewStyle_NoID") private var previewStyle = PreviewStyle.compressed

    var body: some View {
        VStack {
            if page.feedsArray.isEmpty {
                NoFeeds(page: page)
            } else {
                switch pageLayout {
                case .deck:
                    DeckLayout(
                        page: page,
                        profile: profile,
                        hideRead: hideRead,
                        previewStyle: previewStyle
                    )
                case .blend:
                    BlendLayout(
                        page: page,
                        profile: profile,
                        hideRead: hideRead,
                        previewStyle: previewStyle
                    )
                case .showcase:
                    ShowcaseLayout(
                        page: page,
                        profile: profile,
                        hideRead: hideRead,
                        previewStyle: previewStyle
                    )
                case .gadgets:
                    GadgetLayout(
                        page: page,
                        profile: profile,
                        hideRead: hideRead,
                        previewStyle: previewStyle
                    )
                }
            }
        }
        .modifier(URLDropTargetModifier(page: page))
        .navigationTitle(page.displayName)
        .toolbar {
            #if targetEnvironment(macCatalyst)
            ToolbarItem(placement: .secondaryAction) {
                PageLayoutPicker(pageLayout: $pageLayout).pickerStyle(.segmented)
            }
            ToolbarItemGroup(placement: .primaryAction) {
                PreviewStyleButton(previewStyle: $previewStyle)
                AddFeedButton(page: page)
                NavigationLink(value: DetailPanel.pageSettings(page)) {
                    Label("Page Settings", systemImage: "wrench")
                }
                .buttonStyle(ToolbarButtonStyle())
                .accessibilityIdentifier("page-settings-button")
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    PreviewStyleButton(previewStyle: $previewStyle)
                    PageLayoutPicker(pageLayout: $pageLayout)
                    AddFeedButton(page: page)
                    NavigationLink(value: DetailPanel.pageSettings(page)) {
                        Label("Page Settings", systemImage: "wrench")
                    }
                    .accessibilityIdentifier("page-settings-button")
                } label: {
                    Label("Page Menu", systemImage: "ellipsis.circle").fontWeight(.medium)
                }
                .accessibilityIdentifier("page-menu")
            }
            #endif

            ToolbarItemGroup(placement: .bottomBar) {
                PageBottomBar(
                    page: page,
                    profile: profile,
                    refreshing: $refreshing,
                    hideRead: $hideRead
                )
            }
        }
    }

    init(
        page: Page,
        profile: Profile,
        hideRead: Binding<Bool>,
        refreshing: Binding<Bool>
    ) {
        _hideRead = hideRead
        _refreshing = refreshing

        _pageLayout = AppStorage(
            wrappedValue: PageLayout.gadgets,
            "PageLayout_\(page.id?.uuidString ?? "NoID")"
        )
        _previewStyle = AppStorage(
            wrappedValue: PreviewStyle.compressed,
            "PagePreviewStyle_\(page.id?.uuidString ?? "NoID")"
        )

        self.page = page
        self.profile = profile
    }
}
