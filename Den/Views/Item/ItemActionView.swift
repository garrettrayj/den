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

    @ObservedObject var item: Item

    var isLastInList: Bool = false
    var isStandalone: Bool = false
    var showGoToFeed: Bool = true

    @ViewBuilder var content: Content
    
    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false

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
                NavigationLink(value: SubDetailPanel.item(item.objectID.uriRepresentation())) {
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
                ToggleReadButton(item: item)
                ToggleBookmarkedButton(item: item)
            }
            #else
            ToggleReadButton(item: item)
            ToggleBookmarkedButton(item: item)
            #endif
            if let url = item.link {
                SystemBrowserButton(url: url)
                CopyAddressButton(url: url)
                ShareButton(item: url)
            }
            if showGoToFeed, let feedObjectURL = item.feedData?.feed?.objectID.uriRepresentation() {
                Divider()
                GoToFeedNavLink(feedObjectURL: feedObjectURL)
            }
        }
    }
}
