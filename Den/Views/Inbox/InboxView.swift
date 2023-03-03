//
//  InboxView.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct InboxView: View {
    @ObservedObject var profile: Profile
    @Binding var hideRead: Bool

    @SceneStorage("InboxPreviewStyle") private var previewStyle: PreviewStyle = PreviewStyle.compressed

    var body: some View {
        WithItems(
            scopeObject: profile,
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.published, ascending: false)],
            readFilter: hideRead ? false : nil
        ) { _, items in
            GeometryReader { geometry in
                Group {
                    if profile.feedsArray.isEmpty {
                        NoFeedsView()
                    } else if items.isEmpty {
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
                .toolbar {
                    ToolbarItem {
                        if geometry.size.width > 460 {
                            PreviewStyleButtonView(previewStyle: $previewStyle).pickerStyle(.segmented)
                        } else {
                            PreviewStyleButtonView(previewStyle: $previewStyle)
                        }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        InboxBottomBarView(profile: profile, hideRead: $hideRead)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Inbox")
        }
    }
}
