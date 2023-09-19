//
//  TagNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TagNavLink: View {
    #if os(iOS)
    @Environment(\.editMode) private var editMode
    #endif
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var tag: Tag

    var body: some View {
        Label {
            #if os(macOS)
            TextField(text: $tag.wrappedName) { tag.nameText }.badge(tag.bookmarksArray.count)
            #else
            if editMode?.wrappedValue.isEditing == true {
                TextField(text: $tag.wrappedName) { tag.nameText }
            } else {
                tag.nameText.badge(tag.bookmarksArray.count)
            }
            #endif
        } icon: {
            Image(systemName: "tag")
        }
        .lineLimit(1)
        .contentShape(Rectangle())
        .onDrop(
            of: [.denBookmark, .denItem],
            delegate: TagNavDropDelegate(context: viewContext, tag: tag)
        )
        .tag(DetailPanel.tag(tag))
        .accessibilityIdentifier("TagNavLink")
        .contextMenu {
            DeleteTagButton(tag: tag)
        }
    }
}
