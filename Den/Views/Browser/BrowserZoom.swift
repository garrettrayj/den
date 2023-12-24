//
//  BrowserZoom.swift
//  Den
//
//  Created by Garrett Johnson on 10/12/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct BrowserZoom: View {
    @ObservedObject var browserViewModel: BrowserViewModel

    var body: some View {
        ControlGroup {
            Button {
                guard let decreased = browserViewModel.browserZoom.previous() else { return }
                browserViewModel.setBrowserZoom(decreased)
            } label: {
                Label {
                    Text("Zoom Out")
                } icon: {
                    Image(systemName: "minus.magnifyingglass")
                }
            }
            .keyboardShortcut("-", modifiers: .command, localization: .withoutMirroring)

            Button {
                browserViewModel.setBrowserZoom(.oneHundredPercent)
            } label: {
                #if os(macOS)
                Text("Actual Size", comment: "Button label.")
                #else
                Text("\(browserViewModel.browserZoom.rawValue)%", comment: "Zoom level label.")
                #endif
            }
            .keyboardShortcut("0", modifiers: .command, localization: .withoutMirroring)

            Button {
                guard let increased = browserViewModel.browserZoom.next() else { return }
                browserViewModel.setBrowserZoom(increased)
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
