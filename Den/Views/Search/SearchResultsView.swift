//
//  SearchResultsView.swift
//  Den
//
//  Created by Garrett Johnson on 1/9/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct SearchResultsView: View {
    @FetchRequest
    private var searchResults: FetchedResults<Item>

    var query: String

    var body: some View {
        GeometryReader { geometry in
            if searchResults.isEmpty {
                StatusBoxView(message: Text("No results found for “\(query)”"))
            } else {
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: Array(searchResults)) { item in
                        FeedItemPreviewView(item: item)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                if !searchResults.isEmpty {
                    HStack(spacing: 0) {
                        Text("Results for “")
                        Text(query).foregroundColor(.primary)
                        Text("”")
                    }
                    #if targetEnvironment(macCatalyst)
                    .font(.system(size: 11))
                    #else
                    .font(.system(size: 13))
                    #endif
                    .foregroundColor(.secondary)
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
