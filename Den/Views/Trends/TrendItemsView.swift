//
//  TrendDetailView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendItemsView: View {
    @EnvironmentObject private var linkManager: LinkManager

    @AppStorage("hideRead") var hideRead = false

    @ObservedObject var trend: Trend

    var body: some View {
        GeometryReader { geometry in
            if trend.items.isEmpty {
                NoItemsView()
            } else if visibleItems.isEmpty {
                AllReadView(hiddenItemCount: trend.items.read().count)
            } else {
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: visibleItems) { item in
                        FeedItemPreviewView(item: item)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle(trend.wrappedTitle)
        .toolbar {
            ReadingToolbarContent(
                items: trend.items,
                disabled: false,
                hideRead: $hideRead
            ) {
                linkManager.toggleReadUnread(trend: trend)
                trend.items.forEach { $0.objectWillChange.send() }
                trend.objectWillChange.send()
            }
        }
    }

    private var visibleItems: [Item] {
        trend.items.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
