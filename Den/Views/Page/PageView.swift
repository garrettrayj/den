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
    @Environment(\.modelContext) private var modelContext

    @Bindable var page: Page

    @State private var showingDeleteAlert = false
    @State private var showingIconSelector = false
    
    @AppStorage("PageLayout") private var pageLayout: PageLayout = .grouped

    var body: some View {
        if page.isDeleted || page.modelContext == nil {
            ContentUnavailable {
                Label {
                    Text("Folder Deleted", comment: "Object removed message.")
                } icon: {
                    Image(systemName: "trash")
                }
            }
            .navigationTitle("")
        } else {
            WithItems(scopeObject: page) { items in
                Group {
                    if page.wrappedFeeds.isEmpty {
                        NoFeeds()
                    } else if pageLayout == .grouped {
                        GroupedLayout(
                            page: page,
                            items: items
                        )
                    } else if pageLayout == .deck {
                        DeckLayout(
                            page: page,
                            items: items
                        )
                    } else if pageLayout == .timeline {
                        TimelineLayout(
                            page: page,
                            items: items
                        )
                    }
                }
                .frame(minWidth: 320)
                .navigationTitle(page.displayName)
                .navigationTitle($page.wrappedName)
                .toolbar {
                    PageToolbar(
                        page: page,
                        pageLayout: $pageLayout,
                        showingDeleteAlert: $showingDeleteAlert,
                        showingIconSelector: $showingIconSelector,
                        items: items
                    )
                }
                #if os(iOS)
                .alert(
                    Text("Delete Folder?", comment: "Alert title."),
                    isPresented: $showingDeleteAlert,
                    actions: {
                        Button(role: .cancel) {
                            // Pass
                        } label: {
                            Text("Cancel", comment: "Button label.")
                        }
                        DeletePageButton(page: page)
                    },
                    message: {
                        Text("All feeds will removed.", comment: "Delete page alert message.")
                    }
                )
                .sheet(
                    isPresented: $showingIconSelector,
                    content: {
                        IconSelector(selection: $page.wrappedSymbol)
                    }
                )
                #endif
            }
        }
    }

    init(page: Page) {
        self.page = page

        _pageLayout = .init(
            wrappedValue: PageLayout.grouped,
            "PageLayout_\(page.id?.uuidString ?? "NoID")"
        )
    }
}
