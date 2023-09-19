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
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var page: Page
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var showingInspector: Bool

    private var pageLayout: AppStorage<PageLayout>

    var body: some View {
        ZStack {
            if page.managedObjectContext == nil || page.isDeleted {
                ContentUnavailableView {
                    Label {
                        Text("Page Deleted", comment: "Object removed message.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                }
                .navigationTitle("")
            } else {
                WithItems(scopeObject: page) { items in
                    ZStack {
                        if page.feedsArray.isEmpty {
                            NoFeeds()
                        } else {
                            switch pageLayout.wrappedValue {
                            case .deck:
                                DeckLayout(
                                    page: page,
                                    profile: profile,
                                    hideRead: $hideRead,
                                    items: items
                                )
                            case .timeline:
                                TimelineLayout(
                                    page: page,
                                    profile: profile,
                                    hideRead: $hideRead,
                                    items: items
                                )
                            case .showcase:
                                ShowcaseLayout(
                                    page: page,
                                    profile: profile,
                                    hideRead: $hideRead,
                                    items: items
                                )
                            case .grouped:
                                GroupedLayout(
                                    page: page,
                                    profile: profile,
                                    hideRead: $hideRead,
                                    items: items
                                )
                            }
                        }
                    }
                    .id("PageLayout_\(page.id?.uuidString ?? "NoID")")
                    .toolbar {
                        PageToolbar(
                            page: page,
                            hideRead: $hideRead,
                            pageLayout: pageLayout.projectedValue,
                            showingInspector: $showingInspector,
                            items: items
                        )
                    }
                    .navigationTitle(page.nameText)
                    .inspector(isPresented: $showingInspector) {
                        PageInspector(page: page)
                    }
                }
            }
        }
    }

    init(
        page: Page,
        profile: Profile,
        hideRead: Binding<Bool>,
        showingInspector: Binding<Bool>
    ) {
        self.page = page
        self.profile = profile

        _hideRead = hideRead
        _showingInspector = showingInspector

        pageLayout = .init(
            wrappedValue: PageLayout.grouped,
            "PageLayout_\(page.id?.uuidString ?? "NoID")"
        )
    }
}
