//
//  ShowInFinderButton.swift
//  Den
//
//  Created by Garrett Johnson on 4/15/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ShowInFinderButton: View {
    let url: URL
    
    var body: some View {
        Button {
            #if os(macOS)
            if url.hasDirectoryPath {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
            } else {
                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
            #endif
        } label: {
            Label {
                Text("Show in Finder")
            } icon: {
                Image(systemName: "magnifyingglass.circle.fill")
            }
        }
    }
}
