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

    @AppStorage("HideRead") private var hideRead: Bool = false
    @AppStorage("PageLayout_NoID") private var pageLayout = PageLayout.grouped

    @SceneStorage("ShowingPageConfiguration") private var showingPageConfiguration: Bool = false

    var body: some View {
        Group {
            if page.managedObjectContext == nil || page.isDeleted {
                SplashNote(title: Text("Page Deleted", comment: "Object removed message."))
            } else {
                WithItems(scopeObject: page) { items in
                    ZStack {
                        if page.feedsArray.isEmpty {
                            NoFeeds(profile: profile, page: page)
                        } else {
                            switch pageLayout {
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
                    .modifier(URLDropTargetModifier(profile: profile, page: page))
                    .toolbar(id: "Page") {
                        PageToolbar(
                            page: page,
                            profile: profile,
                            hideRead: $hideRead,
                            pageLayout: $pageLayout,
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
            }
        ) {
            PageConfigurationSheet(page: page)
        }
    }

    init(
        page: Page,
        profile: Profile
    ) {
        _pageLayout = AppStorage(
            wrappedValue: PageLayout.grouped,
            "PageLayout_\(page.id?.uuidString ?? "NoID")"
        )

        self.page = page
        self.profile = profile
    }
}
