//
//  SearchResultsView.swift
//  Den
//
//  Created by Garrett Johnson on 1/9/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct SearchResultsView: View {
    @FetchRequest
    private var searchResults: FetchedResults<Item>

    let query: String

    var body: some View {
        GeometryReader { geometry in
            if searchResults.isEmpty {
                SplashNoteView(title: Text("No results found for “\(query)”"))
            } else {
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: Array(searchResults)) { item in
                        FeedItemPreviewView(item: item)
                    }.modifier(MainBoardModifier())
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                if !searchResults.isEmpty {
                    HStack(spacing: 0) {
                        Text("Results for “")
                        Text(query).foregroundColor(.primary)
                        Text("”")
                    }
                    .font(.caption)
                }
            }
        }
    }

    init(searchModel: SearchModel, profile: Profile) {
        self.query = searchModel.query

        let profilePredicate = NSPredicate(
            format: "feedData.id IN %@",
            profile.pagesArray.flatMap({ page in
                page.feedsArray.compactMap { feed in
                    feed.feedData?.id
                }
            })
        )
        let queryPredicate = NSPredicate(
            format: "title CONTAINS[c] %@",
            query.count > 0 ? "\(query)" : ""
        )
        let compoundPredicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [profilePredicate, queryPredicate]
        )

        _searchResults = FetchRequest<Item>(
            entity: Item.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Item.published, ascending: false)
            ],
            predicate: compoundPredicate
        )
    }
}
