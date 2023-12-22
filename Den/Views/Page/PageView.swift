//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//

import SwiftUI

struct PageView: View {
    @Environment(\.minDetailColumnWidth) private var minDetailColumnWidth

    @ObservedObject var page: Page

    @Binding var hideRead: Bool
    @Binding var searchQuery: String
    
    @SceneStorage("ShowingPageInspector") private var showingInspector = false

    private var pageLayout: AppStorage<PageLayout>

    var body: some View {
        if page.managedObjectContext == nil || page.isDeleted {
            ContentUnavailable {
                Label {
                    Text("Page Deleted", comment: "Object removed message.")
                } icon: {
                    Image(systemName: "trash")
                }
            }
            .navigationTitle("")
        } else {
            WithItems(
                scopeObject: page,
                includeExtras: !searchQuery.isEmpty,
                searchQuery: searchQuery
            ) { items in
                Group {
                    if page.feedsArray.isEmpty {
                        NoFeeds()
                    } else if !searchQuery.isEmpty && items.isEmpty {
                        NoSearchResults(searchQuery: $searchQuery)
                    } else if !searchQuery.isEmpty && items.unread().isEmpty && hideRead {
                        NoUnreadSearchResults(searchQuery: $searchQuery)
                    } else {
                        switch pageLayout.wrappedValue {
                        case .grouped:
                            GroupedLayout(
                                page: page,
                                hideRead: $hideRead,
                                searchQuery: $searchQuery,
                                items: items
                            )
                        case .deck:
                            DeckLayout(
                                page: page,
                                hideRead: $hideRead,
                                searchQuery: $searchQuery,
                                items: items
                            )
                        case .timeline:
                            TimelineLayout(
                                page: page,
                                hideRead: $hideRead,
                                items: items
                            )
                        }
                    }
                }
                .frame(minWidth: minDetailColumnWidth)
                .navigationTitle(page.nameText)
                .toolbar {
                    PageToolbar(
                        page: page,
                        hideRead: $hideRead,
                        searchQuery: $searchQuery,
                        showingInspector: $showingInspector,
                        items: items
                    )
                }
                .inspector(isPresented: $showingInspector) {
                    PageInspector(page: page, pageLayout: pageLayout.projectedValue)
                }
            }
        }
    }

    init(
        page: Page,
        hideRead: Binding<Bool>,
        searchQuery: Binding<String>
    ) {
        self.page = page

        _hideRead = hideRead
        _searchQuery = searchQuery

        pageLayout = .init(
            wrappedValue: PageLayout.grouped,
            "PageLayout_\(page.id?.uuidString ?? "NoID")"
        )
    }
}
