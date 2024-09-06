//
//  TrendingLayout.swift
//  Den
//
//  Created by Garrett Johnson on 12/24/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendingLayout: View {
    @Environment(\.hideRead) private var hideRead
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.managedObjectContext) private var viewContext
    
    let trends: FetchedResults<Trend>
    
    var body: some View {
        Group {
            if trends.containingUnread.isEmpty && hideRead {
                AllRead(largeDisplay: true)
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        BoardView(width: geometry.size.width, list: visibleTrends) { trend in
                            TrendBlock(
                                trend: trend,
                                items: trend.items,
                                feeds: trend.feeds
                            )
                        }
                    }
                }
            }
        }
        .toolbar { toolbarContent }
    }
    
    private var visibleTrends: [Trend] {
        let visibleTrends = hideRead ? trends.containingUnread : Array(trends)

        return visibleTrends.sorted {
            ($0.feeds.count, $0.items.count) > ($1.feeds.count, $1.items.count)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            ToggleReadFilterButton()
        }
        ToolbarItem {
            MarkAllReadUnreadButton(allRead: trends.containingUnread.isEmpty) {
                HistoryUtility.toggleRead(items: trends.items, context: viewContext)
            }
        }
        #else
        if horizontalSizeClass == .compact {
            ToolbarItem(placement: .bottomBar) {
                ToggleReadFilterButton()
            }
            ToolbarItem(placement: .status) {
                CommonStatus()
            }
            ToolbarItem(placement: .bottomBar) {
                MarkAllReadUnreadButton(allRead: trends.containingUnread.isEmpty) {
                    HistoryUtility.toggleRead(items: trends.items)
                }
            }
        } else {
            ToolbarItem {
                ToggleReadFilterButton()
            }
            ToolbarItem {
                MarkAllReadUnreadButton(allRead: trends.containingUnread.isEmpty) {
                    HistoryUtility.toggleRead(items: trends.items)
                }
            }
        }
        #endif
    }
}
