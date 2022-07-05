//
//  GlobalTimelineView.swift
//  Den
//
//  Created by Garrett Johnson on 7/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct GlobalTimelineView: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @SectionedFetchRequest<String, Item>(sectionIdentifier: \.day, sortDescriptors: [])
    private var itemSections: SectionedFetchResults<String, Item>

    @Binding var hideRead: Bool

    var frameSize: CGSize

    var body: some View {
        if itemSections.isEmpty {
            StatusBoxView(message: Text("Timeline Empty"), symbol: "clock")
        } else {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(itemSections) { section in
                    Section {
                        BoardView(width: frameSize.width, list: Array(section)) { item in
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
        }
    }

    init(profile: Profile, hideRead: Binding<Bool>, frameSize: CGSize) {
        self.frameSize = frameSize

        _hideRead = hideRead

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
