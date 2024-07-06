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
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    @Bindable var item: Item

    var isLastInList: Bool = false
    var isStandalone: Bool = false

    @ViewBuilder var content: Content
    
    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false

    var body: some View {
        Group {
            if useSystemBrowser {
                Button {
                    guard let url = item.link else { return }
                    openURL(url)
                    HistoryUtility.markItemRead(modelContext: modelContext, item: item)
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
                read: $item.wrappedRead,
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
                BookmarkButton(item: item)
            }
            #else
            ReadUnreadButton(item: item)
            ToggleBookmarkedButton(item: item)
            #endif
            if let url = item.link {
                SystemBrowserButton(url: url)
                CopyAddressButton(url: url)
                ShareButton(item: url)
            }
        }
    }
}
