//
//  BookmarksTableLayout.swift
//  Den
//
//  Created by Garrett Johnson on 2/19/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BookmarksTableLayout: View {
    @Environment(\.self) private var environment
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) private var openURL
    
    @AppStorage("AccentColor") private var accentColor: AccentColor = .coral
    @AppStorage("Viewer") private var viewer: ViewerOption = .builtInViewer
    
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
    @State private var sortOrder = [KeyPathComparator(\Row.created, order: .reverse)]
    @State private var bookmarkToShow: Bookmark?
    @State private var showingBookmark = false
    
    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn(
                Text("Feed", comment: "Tagged items table header."),
                value: \.site
            ) { row in
                if horizontalSizeClass == .compact {
                    VStack(alignment: .leading) {
                        Label {
                            row.bookmark.siteText
                        } icon: {
                            Favicon(url: row.bookmark.favicon) {
                                BookmarkFaviconPlaceholder()
                            }
                        }
                        .font(.callout)
                        .imageScale(.small)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            row.bookmark.titleText.font(.headline)
                            
                            LabeledContent {
                                Text(row.created.formatted())
                            } label: {
                                Text("Added", comment: "Compact bookmarks table row date/time label.")
                            }
                            .font(.caption2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                } else {
                    Label {
                        row.bookmark.siteText
                    } icon: {
                        Favicon(url: row.bookmark.favicon) {
                            BookmarkFaviconPlaceholder()
                        }
                    }
                }
            }
            .width(max: horizontalSizeClass == .compact ? nil : 180)

            TableColumn(
                Text("Title", comment: "Bookmarks table header."),
                value: \.title
            ) { row in
                row.bookmark.titleText
            }
            .width(ideal: 460)

            TableColumn(
                Text("Added", comment: "Bookmarks table header."),
                value: \.created
            ) { row in
                Text(row.created.formatted())
            }
            .width(max: 160)
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
            
            if viewer == .webBrowser {
                guard let url = bookmark?.link else { return }
                openURL(url)
            } else {
                bookmarkToShow = bookmark
                showingBookmark = true
            }
            
            #if os(macOS)
            if viewer == .webBrowser {
                guard let url = bookmark?.link else { return }
                openURL(url)
            } else {
                bookmarkToShow = bookmark
                showingBookmark = true
            }
            #else
            if viewer == .webBrowser {
                guard let url = bookmark?.link else { return }
                openURL(url)
            } else if viewer == .safariView {
                guard let url = bookmark?.link else { return }
                
                InAppSafari.open(
                    url: url,
                    environment: environment,
                    accentColor: accentColor,
                    entersReaderIfAvailable: bookmark?.feed?.readerMode ?? false
                )
            } else {
                bookmarkToShow = bookmark
                showingBookmark = true
            }
            #endif
            
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
            UnbookmarkButton(bookmark: row.bookmark)
            Divider()
            if viewer != .builtInViewer {
                Button {
                    bookmarkToShow = row.bookmark
                    showingBookmark = true
                } label: {
                    Label {
                        Text("Open in Viewer", comment: "Button label.")
                    } icon: {
                        Image(systemName: "doc.text")
                    }
                }
            }
            #if os(iOS)
            if viewer != .safariView {
                SafariViewButton(
                    url: row.link,
                    entersReaderIfAvailable: row.bookmark.feed?.readerMode ?? false
                )
            }
            #endif
            if viewer != .webBrowser {
                SystemBrowserButton(url: row.link)
            }
            CopyLinkButton(url: row.link)
            ShareButton(item: row.link)
            if let feedObjectURL = row.bookmark.feed?.objectID.uriRepresentation() {
                Divider()
                GoToFeedNavLink(feedObjectURL: feedObjectURL)
            }
        } else {
            Button {
                deleteSelection(items: items)
            } label: {
                Text("Unbookmark", comment: "Button label.")
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
