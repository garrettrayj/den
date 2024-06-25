//
//  PagePicker.swift
//  Den
//
//  Created by Garrett Johnson on 5/30/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI

struct PagePicker: View {
    @Binding var selection: Page?
    
    var labelText: Text = Text("Folder", comment: "Picker label.")
    
    @Query(sort: [
        SortDescriptor(\Page.userOrder, order: .forward),
        SortDescriptor(\Page.name, order: .forward)
    ])
    private var pages: [Page]

    var body: some View {
        Picker(selection: $selection) {
            ForEach(pages) { page in
                page.displayName.tag(page as Page?)
            }
        } label: {
            Label {
                labelText
            } icon: {
                Image(systemName: "folder")
            }
        }
    }
}
