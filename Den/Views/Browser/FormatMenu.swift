//
//  FormatMenu.swift
//  Den
//
//  Created by Garrett Johnson on 10/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FormatMenu: View {
    @ObservedObject var browserViewModel: BrowserViewModel
    
    @Binding var browserZoom: PageZoomLevel
    @Binding var readerZoom: PageZoomLevel
    
    var body: some View {
        if browserViewModel.isReaderable {
            Menu {
                menuContent
            } label: {
                menuLabel
            } primaryAction: {
                browserViewModel.toggleReader()
            }
        } else {
            Menu {
                menuContent
            } label: {
                menuLabel
            }
        }
    }
    
    @ViewBuilder
    private var menuContent: some View {
        ToggleReaderButton(browserViewModel: browserViewModel)
        ToggleBlocklistsButton(browserViewModel: browserViewModel)
        ZoomControlGroup(
            zoomLevel: browserViewModel.showingReader ? $readerZoom : $browserZoom
        )
    }
    
    private var menuLabel: some View {
        Label {
            Text("Formatting", comment: "Button label.")
        } icon: {
            if browserViewModel.showingReader {
                Image(systemName: "doc.plaintext.fill")
            } else {
                if browserViewModel.isReaderable {
                    Image(systemName: "doc.plaintext")
                } else {
                    Image(systemName: "textformat.size")
                }
            }
        }
    }
}
