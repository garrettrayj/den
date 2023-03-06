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
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool
    @Binding var hideRead: Bool

    @SceneStorage("TrendPreviewStyle") private var previewStyle: PreviewStyle = PreviewStyle.compressed

    var body: some View {
        WithItems(
            scopeObject: trend,
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.published, ascending: false)],
            readFilter: hideRead ? false : nil
        ) { _, items in
            GeometryReader { geometry in
                Group {
                    if items.isEmpty {
                        AllReadSplashNoteView()
                    } else {
                        ScrollView(.vertical) {
                            BoardView(width: geometry.size.width, list: Array(items)) { item in
                                if previewStyle == .compressed {
                                    FeedItemCompressedView(item: item)
                                } else {
                                    FeedItemExpandedView(item: item)
                                }
                            }.modifier(MainBoardModifier())
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
                .navigationTitle(trend.wrappedTitle)
                .toolbar {
                    ToolbarItem {
                        if geometry.size.width > 460 {
                            PreviewStyleButtonView(previewStyle: $previewStyle).pickerStyle(.segmented)
                        } else {
                            PreviewStyleButtonView(previewStyle: $previewStyle)
                        }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        TrendBottomBarView(trend: trend, profile: profile, refreshing: $refreshing, hideRead: $hideRead)
                    }
                }
            }
        }
    }
}
