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
    @Environment(\.managedObjectContext) private var viewContext

    @SectionedFetchRequest<String, History>(sectionIdentifier: \.day, sortDescriptors: [])
    private var historySections: SectionedFetchResults<String, History>

    var body: some View {
        VStack(spacing: 0) {
            if historySections.isEmpty {
                StatusBoxView(message: Text("History is Empty"), symbol: "clock")
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                        ForEach(historySections) { section in
                            Section {
                                VStack(spacing: 0) {
                                    ForEach(section) { result in
                                        if result.title != nil && result.link != nil {
                                            historyRow(result)
                                        }
                                        if section.last != result {
                                            Divider()
                                        }
                                    }
                                }
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(8)
                                .padding()
                            } header: {
                                Label(section.id, systemImage: "calendar")
                                    .font(.subheadline)
                                    .padding(.horizontal, 28)
                                    .modifier(PinnedSectionHeaderModifier())
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("History")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Text("\(historySections.reduce(0, { $0 + $1.count })) entries").font(.caption)
            }
        }
    }

    init(profile: Profile) {
        let profilePredicate = NSPredicate(
            format: "profile.id == %@",
            profile.id?.uuidString ?? ""
        )
        let visistedPredicate = NSPredicate(
            format: "visited != nil"
        )
        let compoundPredicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [profilePredicate, visistedPredicate]
        )

        _historySections = SectionedFetchRequest<String, History>(
            entity: History.entity(),
            sectionIdentifier: \.day,
            sortDescriptors: [NSSortDescriptor(keyPath: \History.visited, ascending: false)],
            predicate: compoundPredicate
        )
    }

    private func historyRow(_ history: History) -> some View {
        Button { SyncManager.openLink(context: viewContext, url: history.link) } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(history.title ?? "Untitled")
                    .font(.headline.weight(.semibold))
                    .multilineTextAlignment(.leading)

                Text(history.link!.absoluteString)
                    .font(.caption)
                    .foregroundColor(Color(UIColor.link))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
        .buttonStyle(ItemButtonStyle(read: false))
        .accessibilityIdentifier("history-row-button")
    }
}
