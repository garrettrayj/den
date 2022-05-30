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

    var body: some View {
        Group {
            Divider()
            Button {
                linkManager.openLink(url: item.link, logHistoryItem: item, readerMode: feed.readerMode)
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
    }
}
