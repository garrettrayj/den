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
    @AppStorage("PageLayout_NoID") private var pageLayout = PageLayout.gadgets

    @SceneStorage("ShowingPageSettings") private var showingSettings: Bool = false

    var body: some View {
        Group {
            if page.managedObjectContext == nil || page.isDeleted {
                SplashNote(title: Text("Page Deleted", comment: "Object removed message."))
            } else {
                WithItems(scopeObject: page) { items in
                    pageLayoutView(items: items)
                        .modifier(URLDropTargetModifier(page: page))
                        .toolbar {
                            PageToolbar(
                                page: page,
                                profile: profile,
                                hideRead: $hideRead,
                                pageLayout: $pageLayout,
                                showingSettings: $showingSettings,
                                items: items
                            )
                        }
                        .navigationTitle(page.nameText)
                }
            }
        }
        .sheet(
            isPresented: $showingSettings,
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
            PageSettingsSheet(page: page)
        }

    }

    init(
        page: Page,
        profile: Profile
    ) {
        _pageLayout = AppStorage(
            wrappedValue: PageLayout.gadgets,
            "PageLayout_\(page.id?.uuidString ?? "NoID")"
        )

        self.page = page
        self.profile = profile
    }

    @ViewBuilder
    private func pageLayoutView(items: FetchedResults<Item>) -> some View {
        if page.feedsArray.isEmpty {
            NoFeeds(page: page)
        } else {
            switch pageLayout {
            case .deck:
                DeckLayout(
                    page: page,
                    profile: profile,
                    hideRead: $hideRead,
                    items: items
                )
            case .blend:
                BlendLayout(
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
            case .gadgets:
                GadgetLayout(
                    page: page,
                    profile: profile,
                    hideRead: $hideRead,
                    items: items
                )
            }
        }
    }
}
