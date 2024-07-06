//
//  BookmarksLayoutPicker.swift
//  Den
//
//  Created by Garrett Johnson on 2/20/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BookmarksLayoutPicker: View {
    @Binding var tagLayout: TagLayout
    
    var body: some View {
        Picker(selection: $tagLayout) {
            Label {
                Text("Previews", comment: "Tag layout option.")
            } icon: {
                Image(systemName: "square.grid.2x2")
            }
            .tag(TagLayout.previews)
            
            Label {
                Text("List", comment: "Tag layout option.")
            } icon: {
                Image(systemName: "list.dash")
            }
            .tag(TagLayout.list)
        } label: {
            Text("Layout", comment: "Picker label.")
        }
    }
}
