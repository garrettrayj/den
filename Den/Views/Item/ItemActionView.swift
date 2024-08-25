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
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) private var openURL
    #if os(iOS)
    @Environment(\.openURLInSafariView) private var openURLInSafariView
    #endif

    @ObservedObject var item: Item

    var isLastInList: Bool = false
    var isStandalone: Bool = false
    var showGoToFeed: Bool = true

    @ViewBuilder var content: Content
    
    @AppStorage("Viewer") private var viewer: ViewerOption = .builtInViewer

    var body: some View {
        ZStack {
            #if os(macOS)
            if viewer == .webBrowser {
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
            if viewer == .webBrowser {
                Button {
                    guard let url = item.link else { return }
                    openURL(url)
                    HistoryUtility.markItemRead(context: viewContext, item: item)
                } label: {
                    content.modifier(DraggableItemModifier(item: item))
                }
            } else if viewer == .safariView {
                Button {
                    guard let url = item.link else { return }
                    openURLInSafariView(url, item.feedData?.feed?.readerMode)
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
            Divider()
            #endif
            if let url = item.link {
                if viewer != .builtInViewer {
                    NavigationLink(value: SubDetailPanel.item(item.objectID.uriRepresentation())) {
                        Label {
                            Text("Open in Viewer", comment: "Button label.")
                        } icon: {
                            Image(systemName: "doc.text")
                        }
                    }
                }
                #if os(iOS)
                if viewer != .safariView {
                    SafariViewButton(url: url, entersReaderIfAvailable: item.feedData?.feed?.readerMode) {
                        HistoryUtility.markItemRead(context: viewContext, item: item)
                    }
                }
                #endif
                if viewer != .webBrowser {
                    SystemBrowserButton(url: url) {
                        HistoryUtility.markItemRead(context: viewContext, item: item)
                    }
                }
                CopyLinkButton(url: url)
                ShareButton(item: url)
            }
            if showGoToFeed, let feedObjectURL = item.feedData?.feed?.objectID.uriRepresentation() {
                Divider()
                GoToFeedNavLink(feedObjectURL: feedObjectURL)
            }
        }
    }
}
