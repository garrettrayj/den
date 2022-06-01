//
//  GadgetItemView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetItemView: View {
    @EnvironmentObject private var linkManager: LinkManager
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var item: Item
    @ObservedObject var feed: Feed

    @Binding var hideRead: Bool

    var showItem: Bool {
        if item.read && hideRead == true {
            return false
        }

        return true
    }

    var body: some View {
        if showItem {
            VStack(spacing: 0) {
                Divider()
                Button {
                    withAnimation {
                        linkManager.openLink(url: item.link, logHistoryItem: item, readerMode: feed.readerMode)
                    }
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.wrappedTitle).lineLimit(6)

                            if item.published != nil {
                                ItemDateView(date: item.published!, read: item.read)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .multilineTextAlignment(.leading)

                        if feed.showThumbnails == true {
                            ItemThumbnailView(item: item)
                        }
                    }
                    .padding(12)
                }
                .buttonStyle(ItemButtonStyle(read: item.read))
                .accessibilityIdentifier("gadget-item-button")
            }
            .transition(.move(edge: .top))
        }
    }
}
