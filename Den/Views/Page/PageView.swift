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
    
    @SceneStorage("SearchQuery") private var searchQuery: String = ""
    @SceneStorage("ShowingPageInspector") private var showingInspector = false

    @AppStorage("HideRead") private var hideRead: Bool = false

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
                ZStack {
                    if page.feedsArray.isEmpty {
                        NoFeeds()
                    } else if !searchQuery.isEmpty && items.isEmpty {
                        NoSearchResults()
                    } else if !searchQuery.isEmpty && items.unread().isEmpty && hideRead {
                        NoUnreadSearchResults()
                    } else if pageLayout.wrappedValue == .grouped {
                        GroupedLayout(
                            page: page,
                            hideRead: $hideRead,
                            items: items
                        )
                    } else if pageLayout.wrappedValue == .deck {
                        DeckLayout(
                            page: page,
                            hideRead: $hideRead,
                            items: items
                        )
                    } else if pageLayout.wrappedValue == .timeline {
                        TimelineLayout(
                            page: page,
                            hideRead: $hideRead,
                            items: items
                        )
                    }
                }
                .frame(minWidth: minDetailColumnWidth)
                .navigationTitle(page.nameText)
                .modifier(SearchableModifier(searchQuery: $searchQuery))
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

    init(page: Page) {
        self.page = page

        pageLayout = .init(
            wrappedValue: PageLayout.grouped,
            "PageLayout_\(page.id?.uuidString ?? "NoID")"
        )
    }
}
