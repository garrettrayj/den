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

    @Binding var showingNewFeedSheet: Bool

    @AppStorage("HideRead") private var hideRead: Bool = false

    @SceneStorage("ShowingPageConfiguration") private var showingPageConfiguration: Bool = false
    
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
            } else {
                WithItems(scopeObject: page) { items in
                    ZStack {
                        if page.feedsArray.isEmpty {
                            NoFeeds(showingNewFeedSheet: $showingNewFeedSheet)
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
                    .toolbar(id: "Page") {
                        PageToolbar(
                            page: page,
                            hideRead: $hideRead,
                            pageLayout: pageLayout.projectedValue,
                            showingPageConfiguration: $showingPageConfiguration,
                            items: items
                        )
                    }
                    .navigationTitle(page.nameText)
                }
            }
        }
        .sheet(
            isPresented: $showingPageConfiguration,
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
                PageConfigurationSheet(page: page)
            }
        )
    }

    init(
        page: Page,
        profile: Profile,
        showingNewFeedSheet: Binding<Bool>
    ) {
        self.page = page
        self.profile = profile

        _showingNewFeedSheet = showingNewFeedSheet
        
        pageLayout = .init(
            wrappedValue: PageLayout.grouped,
            "PageLayout_\(page.id?.uuidString ?? "NoID")"
        )
    }
}
