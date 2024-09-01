//
//  Bookmarks.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct Bookmarks: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
    private var bookmarks: FetchedResults<Bookmark>
    
    @AppStorage("BookmarksLayout") private var layout: BookmarksLayout = .previews

    var body: some View {
        Group {
            if bookmarks.isEmpty {
                ContentUnavailable {
                    Label {
                        Text("No Bookmarks", comment: "Content unavailable title.")
                    } icon: {
                        Image(systemName: "book")
                    }
                }
            } else if layout == .list {
                BookmarksTableLayout(bookmarks: bookmarks)
            } else {
                BookmarksSpreadLayout(bookmarks: bookmarks)
            }
        }
        .navigationTitle(Text("Bookmarks", comment: "Navigation title."))
        .toolbar {
            ToolbarItem {
                BookmarksLayoutPicker(layout: $layout)
                #if os(macOS)
                .pickerStyle(.inline)
                #else
                .pickerStyle(.menu)
                .labelStyle(.iconOnly)
                .padding(.trailing, -12)
                #endif
            }
        }
    }
}
