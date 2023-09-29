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
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var item: Item
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    var roundedBottom: Bool = false
    var roundedTop: Bool = false

    @ViewBuilder var content: Content

    var body: some View {
        Group {
            if feed.browserView == true, let url = item.link {
                OpenInBrowserButton(
                    url: url,
                    readerMode: feed.readerMode,
                    preTask: {
                        HistoryUtility.markItemRead(context: viewContext, item: item, profile: profile)
                    },
                    label: { content.modifier(DraggableItemModifier(item: item)) }
                )
                .buttonStyle(
                    ItemButtonStyle(read: $item.read, roundedBottom: roundedBottom, roundedTop: roundedTop)
                )
                .accessibilityIdentifier("ItemAction")
            } else {
                NavigationLink(value: SubDetailPanel.item(item)) {
                    content.modifier(DraggableItemModifier(item: item))
                }
                .buttonStyle(
                    ItemButtonStyle(read: $item.read, roundedBottom: roundedBottom, roundedTop: roundedTop)
                )
                .accessibilityIdentifier("ItemAction")
            }
        }
        .contextMenu {
            #if os(iOS)
            ControlGroup {
                ReadUnreadButton(item: item, profile: profile)
                TagsMenu(item: item, profile: profile)
            }
            #else
            ReadUnreadButton(item: item, profile: profile)
            TagsMenu(item: item, profile: profile)
            #endif

            NavigationLink(value: SubDetailPanel.item(item)) {
                Label {
                    Text("Go to Item", comment: "Button label.")
                } icon: {
                    Image(systemName: "chevron.forward")
                }
            }

            if let link = item.link {
                OpenInBrowserButton(
                    url: link,
                    readerMode: feed.readerMode,
                    preTask: {
                        HistoryUtility.markItemRead(context: viewContext, item: item, profile: profile)
                    },
                    label: { OpenInBrowserLabel() }
                )

                Button {
                    PasteboardUtility.copyURL(url: link)
                } label: {
                    Label {
                        Text("Copy Link", comment: "Button label.")
                    } icon: {
                        Image(systemName: "doc.on.doc")
                    }
                }
                ShareButton(url: link)
            }
        }
    }
}
