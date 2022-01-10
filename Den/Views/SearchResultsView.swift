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
    @EnvironmentObject var profileManager: ProfileManager

    @SectionedFetchRequest<String, Item>(sectionIdentifier: \.feedDataId, sortDescriptors: [])
    private var searchResults: SectionedFetchResults<String, Item>

    var query: String = ""

    var body: some View {
        VStack(spacing: 0) {
            if searchResults.isEmpty {
                StatusBoxView(message: "No results found for “\(query)”")
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                        ForEach(searchResults) { section in
                            Section {
                                VStack(spacing: 8) {
                                    ForEach(section) { item in
                                        if item.feedData?.feed != nil {
                                            SearchResultView(item: item)
                                            if item != section.last {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                                .padding(12)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(Color(UIColor.secondarySystemGroupedBackground))
                                )
                                .padding()
                            } header: {
                                FeedTitleLabelView(
                                    title: section.first?.feedData?.feed?.wrappedTitle ?? "Untitled",
                                    faviconImage: section.first?.feedData?.faviconImage
                                ).modifier(PinnedSectionHeaderModifier())
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Search for “\(query)”")
    }

    init(query: String, profile: Profile) {
        self.query = query

        let profilePredicate = NSPredicate(
            format: "feedData.id IN %@",
            profile.pagesArray.flatMap({ page in
                page.feedsArray.compactMap { feed in
                    feed.feedData?.id
                }
            })
        )
        let queryPredicate = NSPredicate(
            format: "title MATCHES[c] %@",
            query.count > 0 ? ".*\\b\(query)\\b.*" : ""
        )
        let compoundPredicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [profilePredicate, queryPredicate]
        )

        _searchResults = SectionedFetchRequest<String, Item>(
            entity: Item.entity(),
            sectionIdentifier: \.feedDataId,
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Item.feedData, ascending: true),
                NSSortDescriptor(keyPath: \Item.published, ascending: false)
            ],
            predicate: compoundPredicate
        )
    }
}
