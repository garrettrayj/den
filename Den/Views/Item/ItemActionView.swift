//
//  ItemActionView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson
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
        if let url = item.link {
            Group {
                if useSystemBrowser {
                    Button {
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
                    roundedTop: isStandalone
                )
            )
            .modifier(PreviewDividerModifier(showDivider: isLastInList || isStandalone))
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
                ShareButton(url: url)
            }
        }
    }
}
