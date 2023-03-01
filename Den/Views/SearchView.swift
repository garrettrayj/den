//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct SearchView: View {
    @FetchRequest(sortDescriptors: [])
    private var searchResults: FetchedResults<Item>

    @ObservedObject var profile: Profile
    @ObservedObject var searchModel: SearchModel

    var body: some View {
        GeometryReader { geometry in
            if searchModel.query == "" {
                SplashNoteView(
                    title: "Searching \(profile.wrappedName)",
                    symbol: "magnifyingglass"
                )
            } else if searchResults.isEmpty {
                SplashNoteView(title: "No items found for “\(searchModel.query)”")
            } else {
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: Array(searchResults)) { item in
                        FeedItemExpandedView(item: item)
                    }.modifier(MainBoardModifier())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Search")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Text("Results for “\(searchModel.query)”").font(.caption)
            }
        }
    }

    init(profile: Profile, searchModel: SearchModel) {
        _searchModel = ObservedObject(wrappedValue: searchModel)
        _profile = ObservedObject(wrappedValue: profile)

        let trimmedQuery = searchModel.query.trimmingCharacters(in: .whitespaces)

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
            trimmedQuery.count > 0 ? "\(trimmedQuery)" : ""
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
