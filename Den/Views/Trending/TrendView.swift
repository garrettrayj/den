//
//  TrendView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct TrendView: View {
    @ObservedObject var trend: Trend

    @Binding var hideRead: Bool

    var body: some View {
        Group {
            if trend.items.isEmpty {
                StatusBoxView(
                    message: Text("Nothing Here"),
                    symbol: "tray"
                )
            } else if visibleItems.isEmpty {
                AllReadStatusView(hiddenItemCount: trend.items.read().count)
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        BoardView(width: geometry.size.width, list: visibleItems) { item in
                            FeedItemPreviewView(item: item)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle(trend.wrappedTitle)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                TrendBottomBarView(
                    trend: trend,
                    hideRead: $hideRead
                )
            }
        }
    }

    private var visibleItems: [Item] {
        trend.items.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
