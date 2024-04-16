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

    var isLastInList: Bool = false
    var isStandalone: Bool = false

    @ViewBuilder var content: Content

    var body: some View {
        Group {
            if useSystemBrowser {
                Button {
                    guard let url = item.link else { return }
                    openURL(url)
                    HistoryUtility.markItemRead(context: viewContext, item: item)
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
            PreviewButtonStyle(
                read: $item.read,
                roundedBottom: isLastInList || isStandalone,
                roundedTop: isStandalone,
                showDivider: !isLastInList && !isStandalone
            )
        )
        .accessibilityIdentifier("ItemAction")
        .contextMenu {
            #if os(iOS)
            ControlGroup {
                ReadUnreadButton(item: item)
                TagsMenu(item: item)
            }
            #else
            ReadUnreadButton(item: item)
            TagsMenu(item: item)
            #endif
            if let url = item.link {
                SystemBrowserButton(url: url)
                CopyAddressButton(url: url)
                ShareLink(item: url)
            }
        }
    }
}
