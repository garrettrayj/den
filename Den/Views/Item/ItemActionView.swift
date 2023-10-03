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
    @Environment(\.openURL) private var openURL
    @Environment(\.useSystemBrowser) private var useSystemBrowser

    @ObservedObject var item: Item
    @ObservedObject var profile: Profile

    var roundedBottom: Bool = false
    var roundedTop: Bool = false

    @ViewBuilder var content: Content

    var body: some View {
        if let url = item.link {
            Group {
                if useSystemBrowser {
                    Button {
                        openURL(url)
                        HistoryUtility.markItemRead(context: viewContext, item: item, profile: profile)
                    } label: {
                        content.modifier(DraggableItemModifier(item: item))
                    }
                } else {
                    NavigationLink(value: SubDetailPanel.item(item)) {
                        content.modifier(DraggableItemModifier(item: item))
                    }
                }
            }
            .buttonStyle(
                PreviewButtonStyle(read: $item.read, roundedBottom: roundedBottom, roundedTop: roundedTop)
            )
            .accessibilityIdentifier("ItemAction")
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
                Button {
                    PasteboardUtility.copyURL(url: url)
                } label: {
                    Label {
                        Text("Copy Link", comment: "Button label.")
                    } icon: {
                        Image(systemName: "doc.on.doc")
                    }
                }
                ShareButton(url: url)
            }
        }
    }
}
