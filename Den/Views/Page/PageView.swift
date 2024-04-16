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
    
    @Binding var hideRead: Bool
    
    @State private var showingDeleteAlert = false
    @State private var showingIconSelector = false

    private var pageLayoutAppStorage: AppStorage<PageLayout>

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
                    } else if pageLayoutAppStorage.wrappedValue == .grouped {
                        GroupedLayout(
                            page: page,
                            hideRead: $hideRead,
                            items: items
                        )
                    } else if pageLayoutAppStorage.wrappedValue == .deck {
                        DeckLayout(
                            page: page,
                            hideRead: $hideRead,
                            items: items
                        )
                    } else if pageLayoutAppStorage.wrappedValue == .timeline {
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
                .frame(minWidth: 320)
                .navigationTitle(page.displayName)
                .navigationTitle($page.wrappedName)
                .toolbar {
                    PageToolbar(
                        page: page,
                        hideRead: $hideRead,
                        pageLayout: pageLayoutAppStorage.projectedValue,
                        showingDeleteAlert: $showingDeleteAlert,
                        showingIconSelector: $showingIconSelector,
                        items: items
                    )
                }
                #if os(iOS)
                .alert(
                    Text("Delete Page?", comment: "Alert title."),
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
                        Text("Feeds will also be deleted.", comment: "Delete page alert message.")
                    }
                )
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

        pageLayoutAppStorage = .init(
            wrappedValue: PageLayout.grouped,
            "PageLayout_\(page.id?.uuidString ?? "NoID")"
        )
    }
}
