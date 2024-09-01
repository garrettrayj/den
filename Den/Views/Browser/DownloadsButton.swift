//
//  DownloadsButton.swift
//  Den
//
//  Created by Garrett Johnson on 3/22/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct DownloadsButton: View {
    @State private var showingPopover = false
    
    var body: some View {
        Button {
            showingPopover = true
        } label: {
            Label {
                Text("Downloads", comment: "Button label.")
            } icon: {
                Image(systemName: "arrow.down.circle")
            }
        }
        .popover(isPresented: $showingPopover, arrowEdge: .top) {
            DownloadsPopover()
        }
        .help(Text("Show downloads", comment: "Button help text."))
        .accessibilityIdentifier("Downloads")
    }
}
