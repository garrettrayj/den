//
//  ZoomControlGroup.swift
//  Den
//
//  Created by Garrett Johnson on 10/12/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ZoomControlGroup: View {
    @Binding var zoomLevel: PageZoomLevel

    var body: some View {
        ControlGroup {
            Button {
                zoomLevel = zoomLevel.previous() ?? zoomLevel
            } label: {
                Label {
                    Text("Zoom Out")
                } icon: {
                    Image(systemName: "minus.magnifyingglass")
                }
            }
            .keyboardShortcut("-", modifiers: .command, localization: .withoutMirroring)

            Button {
                zoomLevel = .oneHundredPercent
            } label: {
                #if os(macOS)
                Text("Actual Size", comment: "Button label.")
                #else
                Text("\(zoomLevel.rawValue)%", comment: "Zoom level label.")
                #endif
            }
            .keyboardShortcut("0", modifiers: .command, localization: .withoutMirroring)

            Button {
                zoomLevel = zoomLevel.next() ?? zoomLevel
            } label: {
                Label {
                    Text("Zoom In")
                } icon: {
                    Image(systemName: "plus.magnifyingglass")
                }
            }
            .keyboardShortcut("=", modifiers: .command, localization: .withoutMirroring)
        } label: {
            Label {
                Text("Zoom", comment: "Control group label.")
            } icon: {
                Image(systemName: "textformat.size")
            }
        }
        #if os(iOS)
        .labelsHidden()
        .controlGroupStyle(.compactMenu)
        #endif
    }
}
