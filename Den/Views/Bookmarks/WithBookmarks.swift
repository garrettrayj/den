//
//  WithBookmarks.swift
//  Den
//
//  Created by Garrett Johnson on 2/19/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI

struct WithBookmarks<Content: View>: View {
    @ViewBuilder let content: ([Bookmark]) -> Content

    @Query()
    private var bookmarks: [Bookmark]

    var body: some View {
        content(bookmarks)
    }

    init(
        sortDescriptors: [SortDescriptor<Bookmark>] = [
            SortDescriptor(\Bookmark.created, order: .reverse)
        ],
        searchQuery: String = "",
        @ViewBuilder content: @escaping ([Bookmark]) -> Content
    ) {
        self.content = content
        
        var request = FetchDescriptor<Bookmark>()
        request.sortBy = sortDescriptors

        _bookmarks = Query(request)
    }
}
