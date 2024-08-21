//
//  ItemActionView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SafariServices
import SwiftUI

struct ItemActionView<Content: View>: View {
    @Environment(\.self) private var environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) private var openURL

    @ObservedObject var item: Item

    var isLastInList: Bool = false
    var isStandalone: Bool = false
    var showGoToFeed: Bool = true

    @ViewBuilder var content: Content
    
    @AppStorage("AccentColor") private var accentColor: AccentColor = .coral
    @AppStorage("Viewer") private var viewer: ViewerOption = .builtInViewer

    var body: some View {
        ZStack {
            #if os(macOS)
            if viewer == .systemBrowser {
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
            #else
            if viewer == .systemBrowser {
                Button {
                    guard let url = item.link else { return }
                    openURL(url)
                    HistoryUtility.markItemRead(context: viewContext, item: item)
                } label: {
                    content.modifier(DraggableItemModifier(item: item))
                }
            } else if viewer == .inAppSafari {
                Button {
                    guard let url = item.link else { return }
                    InAppSafari.open(
                        url: url,
                        environment: environment,
                        accentColor: accentColor,
                        entersReaderIfAvailable: item.feedData?.feed?.readerMode ?? false
                    )
                    HistoryUtility.markItemRead(context: viewContext, item: item)
                } label: {
                    content.modifier(DraggableItemModifier(item: item))
                }
            } else {
                NavigationLink(value: SubDetailPanel.item(item.objectID.uriRepresentation())) {
                    content.modifier(DraggableItemModifier(item: item))
                }
            }
            #endif
        }
        .buttonStyle(
            PreviewButtonStyle(
                read: $item.read,
                roundedBottom: isLastInList || isStandalone,
                roundedTop: isStandalone,
                showDivider: !isLastInList && !isStandalone
            )
        )
        .drawingGroup()
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
