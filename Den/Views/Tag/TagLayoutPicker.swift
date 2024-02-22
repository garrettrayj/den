//
//  TagLayoutPicker.swift
//  Den
//
//  Created by Garrett Johnson on 2/20/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TagLayoutPicker: View {
    @Binding var tagLayout: TagLayout
    
    var body: some View {
        Picker(selection: $tagLayout) {
            Label {
                Text("Previews")
            } icon: {
                Image(systemName: "square.grid.2x2")
            }
            .tag(TagLayout.spread)
            
            Label {
                Text("Table")
            } icon: {
                Image(systemName: "list.bullet")
            }
            .tag(TagLayout.list)
        } label: {
            Text("Layout")
        }
    }
}
