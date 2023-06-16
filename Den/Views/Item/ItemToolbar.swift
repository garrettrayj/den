//
//  ItemToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemToolbar: ToolbarContent {
    @Environment(\.openURL) private var openURL
    @Environment(\.useSystemBrowser) private var useSystemBrowser
    
    @ObservedObject var item: Item
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            Button {
                if let url = item.link {
                    if useSystemBrowser {
                        openURL(url)
                    } else {
                        SafariUtility.openLink(
                            url: url,
                            controlTintColor: profile.tintColor ?? .accentColor,
                            readerMode: feed.readerMode
                        )
                    }
                }
            } label: {
                Label {
                    Text("Open in Browser", comment: "Toolbar button label.")
                } icon: {
                    Image(systemName: "link.circle")
                }
            }
            .buttonStyle(ToolbarButtonStyle())
            .accessibilityIdentifier("item-open-button")
        }
        #else
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            Button {
                if let url = item.link {
                    if useSystemBrowser {
                        openURL(url)
                    } else {
                        SafariUtility.openLink(
                            url: url,
                            controlTintColor: profile.tintColor ?? .accentColor,
                            readerMode: feed.readerMode
                        )
                    }
                }
            } label: {
                Label {
                    Text("Open in Browser", comment: "Toolbar button label.")
                } icon: {
                    Image(systemName: "link.circle")
                }
            }
            .buttonStyle(PlainToolbarButtonStyle())
            .accessibilityIdentifier("item-open-button")
        }
        #endif
        
        if let link = item.link {
            ToolbarItem {
                ShareLink(item: link) {
                    Label {
                        Text("Share…", comment: "Toolbar button label.")
                    } icon: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .buttonStyle(ToolbarButtonStyle())
            }
        }
    }
}
