//
//  TimelineView.swift
//  Den
//
//  Created by Garrett Johnson on 7/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct TimelineView: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @SectionedFetchRequest<String, Item>(sectionIdentifier: \.day, sortDescriptors: [])
    private var itemSections: SectionedFetchResults<String, Item>

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if itemSections.isEmpty {
                    StatusBoxView(message: Text("Timeline Empty"), symbol: "clock")
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                            ForEach(itemSections) { section in
                                Section {
                                    BoardView(width: geometry.size.width, list: Array(section)) { item in
                                        FeedItemPreviewView(item: item)
                                    }
                                    .padding()
                                } header: {
                                    Label(section.id, systemImage: "calendar")
                                        .font(.subheadline)
                                        .padding(.horizontal, 28)
                                        .modifier(PinnedSectionHeaderModifier())
                                }
                            }
                        }
                        #if targetEnvironment(macCatalyst)
                        .padding(.top, 8)
                        #endif
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                VStack {
                    Text("Hello")
                }.font(.caption)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Timeline")
    }

    init(profile: Profile) {
        let profilePredicate = NSPredicate(
            format: "feedData.id IN %@",
            profile.pagesArray.flatMap({ page in
                page.feedsArray.compactMap { feed in
                    feed.feedData?.id
                }
            })
        )

        _itemSections = SectionedFetchRequest<String, Item>(
            entity: Item.entity(),
            sectionIdentifier: \.day,
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.published, ascending: false)],
            predicate: profilePredicate
        )
    }
}
