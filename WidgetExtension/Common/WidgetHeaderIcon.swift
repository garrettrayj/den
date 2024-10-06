//
//  WidgetHeaderIcon.swift
//  Den
//
//  Created by Garrett Johnson on 10/5/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct WidgetHeaderIcon: View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    let entry: LatestItemsEntry
    
    var body: some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            if entry.sourceType == Feed.self {
                if let favicon = entry.faviconImage {
                    favicon
                        .resizable()
                        .widgetAccentedRenderingMode(.fullColor)
                        .clipShape(
                            RoundedRectangle(cornerRadius: widgetFamily == .systemSmall ? 4 : 2)
                        )
                } else {
                    Image(systemName: "dot.radiowaves.up.forward")
                        .resizable()
                        .widgetAccentedRenderingMode(.accented)
                }
            } else if entry.sourceType == Page.self {
                if let symbol = entry.symbol {
                    Image(systemName: symbol).resizable().widgetAccentedRenderingMode(.accented)
                }
            } else if entry.unread > 0 {
                Image(systemName: "tray.full").resizable().widgetAccentedRenderingMode(.accented)
            } else {
                Image(systemName: "tray").resizable().widgetAccentedRenderingMode(.accented)
            }
        } else {
            if entry.sourceType == Feed.self {
                if let favicon = entry.faviconImage {
                    favicon.resizable().clipShape(RoundedRectangle(
                        cornerRadius: widgetFamily == .systemSmall ? 4 : 2
                    ))
                } else {
                    Image(systemName: "dot.radiowaves.up.forward").resizable()
                }
            } else if entry.sourceType == Page.self {
                if let symbol = entry.symbol {
                    Image(systemName: symbol).resizable()
                }
            } else if entry.unread > 0 {
                Image(systemName: "tray.full").resizable()
            } else {
                Image(systemName: "tray").resizable()
            }
        }
    }
}
