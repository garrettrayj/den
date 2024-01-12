//
//  FeedLayoutSection.swift
//  Den
//
//  Created by Garrett Johnson on 1/11/24.
//  Copyright © 2024 Garrett Johnson
//

import SwiftUI

struct FeedLayoutSection: View {
    @ObservedObject var feed: Feed
    
    @Binding var hideRead: Bool
    
    let geometry: GeometryProxy
    let header: Text
    let items: [Item]
    
    var body: some View {
        Section {
            if items.unread().isEmpty && hideRead {
                AllRead(largeDisplay: true)
            } else {
                BoardView(
                    width: geometry.size.width,
                    list: items.visibilityFiltered(hideRead ? false : nil)
                ) { item in
                    ItemActionView(item: item, isStandalone: true) {
                        if feed.wrappedPreviewStyle == .expanded {
                            ItemPreviewExpanded(item: item, feed: feed)
                        } else {
                            ItemPreviewCompressed(item: item, feed: feed)
                        }
                    }
                }
                .modifier(SafeAreaModifier(geometry: geometry))
            }
        } header: {
            HStack {
                header.font(.title2.weight(.medium))
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.fill.tertiary)
        }
    }
}
