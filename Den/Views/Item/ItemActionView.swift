//
//  ItemActionView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemActionView<Content: View>: View {
    @ObservedObject var item: Item
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @ViewBuilder var content: Content

    var body: some View {
        Group {
            if feed.browserView == true, let url = item.link {
                OpenInBrowserButton(url: url, readerMode: feed.readerMode) {
                    content.modifier(DraggableItemModifier(item: item))
                }
                .buttonStyle(ItemButtonStyle(read: $item.read))
                .accessibilityIdentifier("ItemAction")
            } else {
                NavigationLink(value: SubDetailPanel.item(item)) {
                    content.modifier(DraggableItemModifier(item: item))
                }
                .buttonStyle(ItemButtonStyle(read: $item.read))
                .accessibilityIdentifier("ItemAction")
            }
        }
        .contextMenu {
            #if os(iOS)
            ControlGroup {
                ReadUnreadButton(item: item)
                TagsMenu(item: item, profile: profile)
            }
            #else
            ReadUnreadButton(item: item)
            TagsMenu(item: item, profile: profile)
            #endif

            NavigationLink(value: SubDetailPanel.item(item)) {
                Label {
                    Text("Go to Item", comment: "Context Button label.")
                } icon: {
                    Image(systemName: "chevron.forward")
                }
            }

            if let link = item.link {
                OpenInBrowserButton(url: link, readerMode: feed.readerMode) {
                    OpenInBrowserLabel()
                }

                Button {
                    PasteboardUtility.copyURL(url: link)
                } label: {
                    Label {
                        Text("Copy Link", comment: "Context Button label.")
                    } icon: {
                        Image(systemName: "doc.on.doc")
                    }
                }
                ShareButton(url: link)
            }
        }
    }
}
