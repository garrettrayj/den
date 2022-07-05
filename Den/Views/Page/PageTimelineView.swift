//
//  PageTimelineView.swift
//  Den
//
//  Created by Garrett Johnson on 2/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageTimelineView: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var page: Page

    @Binding var hideRead: Bool

    @SectionedFetchRequest<String, Item>(sectionIdentifier: \.day, sortDescriptors: [])
    private var itemSections: SectionedFetchResults<String, Item>

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

    private var visibleItems: [Item] {
        page.limitedItemsArray.filter { item in
            hideRead ? item.read == false : true
        }
    }

    init(page: Page, hideRead: Binding<Bool>, frameSize: CGSize) {
        self.page = page
        self.frameSize = frameSize

        _hideRead = hideRead

        let pagePredicate = NSPredicate(
            format: "feedData.id IN %@",
            page.feedsArray.compactMap { feed in
                feed.feedData?.id
            }
        )

        _itemSections = SectionedFetchRequest<String, Item>(
            entity: Item.entity(),
            sectionIdentifier: \.day,
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.published, ascending: false)],
            predicate: pagePredicate
        )
    }
}
