//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct SearchView: View {
    var query: String = ""
    var pattern: String = ""

    @FetchRequest var fetchRequest: FetchedResults<Item>

    var message: String {
        if query.count > 2 {
            return "Results for \"\(query)\""
        }

        return "Search requires at least three characters"
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16, pinnedViews: .sectionHeaders) {
                Section(
                    header: Text(message)
                        .font(.title3)
                        .modifier(PinnedSectionHeaderModifier())
                ) {
                    if groupedResults.count > 0 {
                        BoardView(list: groupedResults, content: { resultGroup in
                            SearchResultView(items: resultGroup.items)
                        })
                        .padding(.horizontal)
                        .padding(.bottom)
                    } else {
                        Text("No results found").modifier(SimpleMessageModifier())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Search")
    }

    private var groupedResults: [SearchResultGroup] {
        let compacted: [Item] = fetchRequest.compactMap { item in
            item.feedData?.feed != nil ? item : nil
        }

        let grouped = Dictionary(grouping: compacted) { item in
            item.feedData!
        }.values.sorted { aItem, bItem in
            guard
                let aTitle = aItem[0].feedData?.feed?.wrappedTitle,
                let bTitle = bItem[0].feedData?.feed?.wrappedTitle
            else {
                return false
            }

            return aTitle < bTitle
        }

        return grouped.compactMap { items in
            guard let id = items.first?.feedData?.feed?.id else { return nil }
            return SearchResultGroup(id: id, items: items)
        }
    }

    init(query: String) {
        self.query = query

        if query.count > 3 {
            self.pattern = ".*\\b\(query)\\b.*"
        }

        _fetchRequest = FetchRequest<Item>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.published, ascending: false)],
            predicate: NSPredicate(format: "%K MATCHES %@", #keyPath(Item.title), pattern)
        )
    }
}

class SearchResultGroup: Identifiable, Equatable, Hashable {
    var id: UUID
    var items: [Item]

    init(id: UUID, items: [Item]) {
        self.id = id
        self.items = items
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SearchResultGroup, rhs: SearchResultGroup) -> Bool {
        return lhs.id == rhs.id
    }
}
