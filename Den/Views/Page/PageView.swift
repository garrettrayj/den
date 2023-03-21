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
                NoFeedsView(page: page)
            } else {
                switch pageLayout {
                case .deck:
                    DeckLayoutView(
                        page: page,
                        hideRead: hideRead,
                        previewStyle: previewStyle
                    )
                case .blend:
                    BlendLayoutView(
                        page: page,
                        hideRead: hideRead,
                        previewStyle: previewStyle
                    )
                case .showcase:
                    ShowcaseLayoutView(
                        page: page,
                        hideRead: hideRead,
                        previewStyle: previewStyle
                    )
                case .gadgets:
                    GadgetLayoutView(
                        page: page,
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
            ToolbarItemGroup {
                PageLayoutPickerView(pageLayout: $pageLayout).pickerStyle(.segmented)
                PreviewStyleButtonView(previewStyle: $previewStyle)
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
