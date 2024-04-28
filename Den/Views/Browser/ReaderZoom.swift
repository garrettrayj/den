//
//  ReaderZoom.swift
//  Den
//
//  Created by Garrett Johnson on 12/24/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ReaderZoom: View {
    @ObservedObject var browserViewModel: BrowserViewModel

    var body: some View {
        ControlGroup {
            Button {
                guard let decreased = browserViewModel.readerZoom.previous() else { return }
                browserViewModel.setReaderZoom(decreased)
            } label: {
                Label {
                    Text("Zoom Out", comment: "Button label.")
                } icon: {
                    Image(systemName: "minus.magnifyingglass")
                }
            }
            .keyboardShortcut("-", modifiers: .command)

            Button {
                browserViewModel.setReaderZoom(.oneHundredPercent)
            } label: {
                #if os(macOS)
                Text("Actual Size", comment: "Button label.")
                #else
                Text("\(browserViewModel.readerZoom.rawValue)%", comment: "Zoom level label.")
                #endif
            }
            .keyboardShortcut("0", modifiers: .command)

            Button {
                guard let increased = browserViewModel.readerZoom.next() else { return }
                browserViewModel.setReaderZoom(increased)
            } label: {
                Label {
                    Text("Zoom In", comment: "Button label.")
                } icon: {
                    Image(systemName: "plus.magnifyingglass")
                }
            }
            .keyboardShortcut("=", modifiers: .command)
        } label: {
            Label {
                Text("Zoom", comment: "Control group label.")
            } icon: {
                Image(systemName: "textformat.size")
            }
        }
        #if os(iOS)
        .menuActionDismissBehavior(.disabled)
        .labelsHidden()
        .controlGroupStyle(.compactMenu)
        #endif
    }
}
