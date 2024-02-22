//
//  TagTableLayout.swift
//  Den
//
//  Created by Garrett Johnson on 2/19/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TagTableLayout: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) private var openURL
    @Environment(\.useSystemBrowser) private var useSystemBrowser
    
    struct Row: Hashable, Identifiable {
        var id: UUID
        var bookmark: Bookmark
        var site: String
        var title: String
        var created: Date
        var link: URL
    }
    
    let bookmarks: FetchedResults<Bookmark>

    @State private var selection = Set<Row.ID>()
    @State private var sortOrder = [KeyPathComparator(\Row.created)]
    @State private var bookmarkToShow: Bookmark?
    @State private var showingBookmark = false
    
    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Feed", value: \.site) { row in
                Label {
                    row.bookmark.siteText
                } icon: {
                    Favicon(url: row.bookmark.favicon) {
                        BookmarkFaviconPlaceholder()
                    }
                }
            }.width(max: 200)

            TableColumn("Title", value: \.title) { row in
                row.bookmark.titleText
            }.width(ideal: 460)

            TableColumn("Tagged", value: \.created) { row in
                Text("\(row.created.formatted())")
            }.width(max: 160)
        } rows: {
            ForEach(rows) { row in
                TableRow(row)
                    .draggable(
                        TransferableBookmark(
                            objectURI: row.bookmark.objectID.uriRepresentation(),
                            linkURL: row.link
                        )
                    )
            }
        }
        .navigationDestination(isPresented: $showingBookmark) {
            if let bookmarkToShow = bookmarkToShow {
                BookmarkView(bookmark: bookmarkToShow)
            }
        }
        .contextMenu(forSelectionType: Row.ID.self) { items in
            contextMenu(items: items)
        } primaryAction: { items in
            let bookmark = bookmarks.filter { $0.id == items.first }.first
            
            if useSystemBrowser {
                guard let url = bookmark?.link else { return }
                openURL(url)
            } else {
                bookmarkToShow = bookmark
                showingBookmark = true
            }
        }
    }
    
    private var rows: [Row] {
        bookmarks.compactMap { bookmark in
            guard
                let id = bookmark.id,
                let link = bookmark.link
            else { return nil }

            return Row(
                id: id,
                bookmark: bookmark,
                site: bookmark.wrappedSite,
                title: bookmark.wrappedTitle,
                created: bookmark.created ?? Date(timeIntervalSince1970: 0),
                link: link
            )
        }
        .sorted(using: sortOrder)
    }
    
    @ViewBuilder
    private func contextMenu(items: Set<Row.ID>) -> some View {
        if items.count == 1, let row = rows.filter({ $0.id == items.first }).first {
            UntagButton(bookmark: row.bookmark)
            SystemBrowserButton(url: .constant(row.link))
            CopyLinkButton(url: .constant(row.link))
            ShareButton(url: .constant(row.link))
        } else {
            Button {
                deleteSelection(items: items)
            } label: {
                Text("Untag")
            }
        }
    }
    
    private func deleteSelection(items: Set<Row.ID>) {
        rows.filter { items.contains($0.id) }.forEach { viewContext.delete($0.bookmark) }
        
        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
