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
    @SectionedFetchRequest<String, Item>(sectionIdentifier: \.feedTitle, sortDescriptors: [])
    private var searchResults: SectionedFetchResults<String, Item>

    var query: String

    var body: some View {
        Group {
            if searchResults.isEmpty {
                StatusBoxView(message: Text("No results found for “\(query)”"))
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                        ForEach(searchResults) { section in
                            resultsSection(section)
                        }
                    }
                    #if targetEnvironment(macCatalyst)
                    .padding(.top, 8)
                    #endif
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                if !searchResults.isEmpty {
                    HStack(spacing: 0) {
                        Text("Showing results for “")
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
            sectionIdentifier: \.feedTitle,
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Item.feedData?.feedTitle, ascending: true),
                NSSortDescriptor(keyPath: \Item.published, ascending: false)
            ],
            predicate: compoundPredicate
        )
    }

    private func resultsSection(_ section: SectionedFetchResults<String, Item>.Element) -> some View {
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
            .background(Color(UIColor.secondarySystemGroupedBackground))
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
