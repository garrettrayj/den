//
//  TrendView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct TrendView: View {
    @ObservedObject var trend: Trend

    @Binding var hideRead: Bool

    var body: some View {
        Group {
            if trend.visibleItems(hideRead).isEmpty {
                AllReadStatusView(hiddenItemCount: trend.items.read().count)
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        BoardView(width: geometry.size.width, list: trend.visibleItems(hideRead)) { item in
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
}
