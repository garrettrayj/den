//
//  HistoryView.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var linkManager: LinkManager

    @FetchRequest(sortDescriptors: [SortDescriptor(\.visited, order: .reverse)])
    private var history: FetchedResults<History>

    var body: some View {
        VStack(spacing: 0) {
            if history.count > 0 {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                        ForEach(groupedResults, id: \.self) { resultGroup in
                            resultsSection(resultGroup: resultGroup)
                        }
                    }
                }
            } else {
                Text("Empty").modifier(SimpleMessageModifier())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("History")
    }

    private var groupedResults: [[History]] {
        let compacted: [History] = history.compactMap { history in
            history.visited != nil ? history : nil
        }

        let results = Dictionary(
            grouping: compacted,
            by: { DateFormatter.fullNone.string(from: $0.visited!) }
        )

        return results.values.sorted { aHistory, bHistory in
            return aHistory[0].visited! > bHistory[0].visited!
        }
    }

    private func resultsSection(resultGroup: [History]) -> some View {
        Section(
            header:
                Text("\(resultGroup.first!.visited!, formatter: DateFormatter.fullNone)")
                    .font(.subheadline)
                    .modifier(PinnedSectionHeaderModifier())
        ) {
            VStack(spacing: 0) {
                ForEach(resultGroup) { result in
                    if result.title != nil && result.link != nil {
                        VStack(alignment: .leading, spacing: 2) {
                            Button { linkManager.openLink(url: result.link) } label: {
                                Text(result.title!)
                                    .font(.title3)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(Color(UIColor.systemPurple))
                            }
                            Text(result.link!.absoluteString)
                                .font(.caption)
                                .foregroundColor(Color.secondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)

                        if resultGroup.last != result {
                            Divider()
                        }
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color(UIColor.secondarySystemGroupedBackground))
            )
            .padding()
        }
    }
}
