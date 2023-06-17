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

    @AppStorage("PageLayout_NoID") private var pageLayout = PageLayout.gadgets
    
    @State private var showingSettings: Bool = false

    var body: some View {
        if page.managedObjectContext == nil {
            SplashNote(title: Text("Page Deleted", comment: "Object removed message."))
        } else {
            WithItems(scopeObject: page) { items in
                ZStack {
                    if page.feedsArray.isEmpty {
                        NoFeeds(page: page)
                    } else {
                        switch pageLayout {
                        case .deck:
                            DeckLayout(
                                page: page,
                                profile: profile,
                                hideRead: hideRead,
                                items: items
                            )
                        case .blend:
                            BlendLayout(
                                page: page,
                                profile: profile,
                                hideRead: hideRead,
                                items: items
                            )
                        case .showcase:
                            ShowcaseLayout(
                                page: page,
                                profile: profile,
                                hideRead: hideRead,
                                items: items
                            )
                        case .gadgets:
                            GadgetLayout(
                                page: page,
                                profile: profile,
                                hideRead: hideRead,
                                items: items
                            )
                        }
                    }
                }
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
        }
    }

    init(
        page: Page,
        profile: Profile,
        hideRead: Binding<Bool>
    ) {
        _hideRead = hideRead
        _pageLayout = AppStorage(
            wrappedValue: PageLayout.gadgets,
            "PageLayout_\(page.id?.uuidString ?? "NoID")"
        )

        self.page = page
        self.profile = profile
    }
}
