//
//  SidebarTag.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SidebarTag: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var tag: Tag

    var body: some View {
        Label {
            #if os(macOS)
            TextField(text: $tag.wrappedName) { tag.displayName }
            #else
            tag.displayName
            #endif
        } icon: {
            Image(systemName: "tag")
        }
        .tag(DetailPanel.tag(tag))
        .contentShape(Rectangle())
        .onDrop(
            of: [.denBookmark, .denItem],
            delegate: TagNavDropDelegate(modelContext: modelContext, tag: tag)
        )
        .accessibilityIdentifier("SidebarTag")
        .contextMenu {
            DeleteTagButton(tag: tag)
        }
    }
}
