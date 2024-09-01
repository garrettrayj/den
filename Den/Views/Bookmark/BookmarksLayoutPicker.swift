//
//  BookmarksLayoutPicker.swift
//  Den
//
//  Created by Garrett Johnson on 2/20/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BookmarksLayoutPicker: View {
    @Binding var layout: BookmarksLayout
    
    var body: some View {
        Picker(selection: $layout) {
            Label {
                Text("Previews", comment: "Bookmarks layout option.")
            } icon: {
                Image(systemName: "square.grid.2x2")
            }
            .tag(BookmarksLayout.previews)
            
            Label {
                Text("List", comment: "Bookmarks layout option.")
            } icon: {
                Image(systemName: "list.dash")
            }
            .tag(BookmarksLayout.list)
        } label: {
            Text("View", comment: "Picker label.")
        }
    }
}
