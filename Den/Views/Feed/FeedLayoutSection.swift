//
//  FeedLayoutSection.swift
//  Den
//
//  Created by Garrett Johnson on 1/11/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedLayoutSection<Header: View>: View {
    @Environment(\.hideRead) private var hideRead
    
    @ObservedObject var feed: Feed
    
    let geometry: GeometryProxy
    let items: [Item]
    
    @ViewBuilder var header: Header
    
    var body: some View {
        Section {
            if items.unread.isEmpty && hideRead {
                AllRead(largeDisplay: true)
            } else {
                BoardView(
                    width: geometry.size.width,
                    list: items.visibilityFiltered(hideRead ? false : nil)
                ) { item in
                    ItemActionView(item: item, isStandalone: true, showGoToFeed: false) {
                        if feed.wrappedPreviewStyle == .expanded {
                            ItemPreviewExpanded(item: item, feed: feed)
                        } else {
                            ItemPreviewCompressed(item: item, feed: feed)
                        }
                    }
                }
                .modifier(SafeAreaModifier(geometry: geometry))
                .drawingGroup()
            }
        } header: {
            HStack {
                header.font(.title3)
                Spacer()
            }
            .modifier(SafeAreaModifier(geometry: geometry))
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.fill.quaternary)
        }
    }
}
