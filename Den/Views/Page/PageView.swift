//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct PageView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.minDetailColumnWidth) private var minDetailColumnWidth

    @ObservedObject var page: Page
    
    @Binding var hideRead: Bool
    
    @State private var showingIconSelector: Bool = false

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
            WithItems(scopeObject: page) { items in
                ZStack {
                    if page.feedsArray.isEmpty {
                        NoFeeds()
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
                .onChange(of: page.name) {
                    guard !page.isDeleted else { return }

                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
                .frame(minWidth: minDetailColumnWidth)
                .navigationTitle(page.displayName)
                .navigationTitle($page.wrappedName)
                .toolbar {
                    PageToolbar(
                        page: page,
                        hideRead: $hideRead,
                        pageLayout: pageLayout.projectedValue,
                        showingIconSelector: $showingIconSelector,
                        items: items
                    )
                }
                #if os(iOS)
                .sheet(
                    isPresented: $showingIconSelector,
                    onDismiss: {
                        if viewContext.hasChanges {
                            do {
                                try viewContext.save()
                            } catch {
                                CrashUtility.handleCriticalError(error as NSError)
                            }
                        }
                    },
                    content: {
                        IconSelector(selection: $page.wrappedSymbol)
                    }
                )
                #endif
            }
        }
    }

    init(page: Page, hideRead: Binding<Bool>) {
        self.page = page
        
        _hideRead = hideRead

        pageLayout = .init(
            wrappedValue: PageLayout.grouped,
            "PageLayout_\(page.id?.uuidString ?? "NoID")"
        )
    }
}
