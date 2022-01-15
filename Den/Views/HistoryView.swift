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

    @SectionedFetchRequest<String, History>(sectionIdentifier: \.day, sortDescriptors: [])
    private var historySections: SectionedFetchResults<String, History>

    var body: some View {
        VStack(spacing: 0) {
            if historySections.count > 0 {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                        ForEach(historySections) { section in
                            Section {
                                VStack(spacing: 0) {
                                    ForEach(section) { result in
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
                                            .padding(.vertical, 8)

                                            if section.last != result {
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
                            } header: {
                                Text(section.id).font(.subheadline).modifier(PinnedSectionHeaderModifier())
                            }
                        }
                    }
                    #if targetEnvironment(macCatalyst)
                    .padding(.top, 8)
                    #endif
                }
            } else {
                StatusBoxView(message: "History is Empty", symbol: "clock")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("History")
    }

    init(profile: Profile) {
        let profilePredicate = NSPredicate(
            format: "profile.id == %@",
            profile.id?.uuidString ?? ""
        )

        _historySections = SectionedFetchRequest<String, History>(
            entity: History.entity(),
            sectionIdentifier: \.day,
            sortDescriptors: [NSSortDescriptor(keyPath: \History.visited, ascending: true)],
            predicate: profilePredicate
        )
    }
}
