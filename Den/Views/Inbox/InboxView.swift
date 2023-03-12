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
    @Binding var refreshing: Bool

    @AppStorage("InboxPreviewStyle_NA") private var previewStyle: PreviewStyle = PreviewStyle.compressed

    var body: some View {
        WithItems(
            scopeObject: profile,
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.published, ascending: false)],
            readFilter: hideRead ? false : nil
        ) { _, items in
            GeometryReader { geometry in
                VStack {
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
                        }.id("inbox_\(profile.id?.uuidString ?? "na")_\(previewStyle)")
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
                        InboxBottomBarView(profile: profile, refreshing: $refreshing, hideRead: $hideRead)
                    }
                }
            }
            .navigationTitle("Inbox")
        }
    }
    
    init(profile: Profile, hideRead: Binding<Bool>, refreshing: Binding<Bool>) {
        self.profile = profile
        
        _hideRead = hideRead
        _refreshing = refreshing
        
        _previewStyle = AppStorage(
            wrappedValue: PreviewStyle.compressed,
            "InboxPreviewStyle_\(profile.id?.uuidString ?? "NA")"
        )
    }
}
