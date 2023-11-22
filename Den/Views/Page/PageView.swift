//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//

import SwiftUI

struct PageView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.minDetailColumnWidth) private var minDetailColumnWidth

    @ObservedObject var page: Page
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    
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
            WithItems(scopeObject: page) { items in
                Group {
                    if page.feedsArray.isEmpty {
                        NoFeeds()
                    } else {
                        switch pageLayout.wrappedValue {
                        case .grouped:
                            GroupedLayout(
                                page: page,
                                profile: profile,
                                hideRead: $hideRead,
                                items: items
                            )
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
                        }
                    }
                }
                .frame(minWidth: minDetailColumnWidth)
                .navigationTitle(page.nameText)
                .inspector(isPresented: $showingInspector) {
                    PageInspector(page: page)
                }
                .toolbar {
                    PageToolbar(
                        page: page,
                        hideRead: $hideRead,
                        pageLayout: pageLayout.projectedValue,
                        showingInspector: $showingInspector,
                        items: items
                    )
                }
                .toolbarBackground(toolbarBackground)
            }
        }
    }
    
    private var toolbarBackground: Visibility {
        #if os(iOS)
        if pageLayout.wrappedValue == .deck {
            return .visible
        }
        if showingInspector && horizontalSizeClass != .compact {
            return .visible
        }
        #endif
                
        return .automatic
    }

    init(
        page: Page,
        profile: Profile,
        hideRead: Binding<Bool>
    ) {
        self.page = page
        self.profile = profile

        _hideRead = hideRead

        pageLayout = .init(
            wrappedValue: PageLayout.grouped,
            "PageLayout_\(page.id?.uuidString ?? "NoID")"
        )
    }
}
