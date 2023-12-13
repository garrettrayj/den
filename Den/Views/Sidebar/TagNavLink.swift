//
//  TagNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct TagNavLink: View {
    #if os(iOS)
    @Environment(\.editMode) private var editMode
    #endif
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var tag: Tag

    var body: some View {
        NavigationLink(value: DetailPanel.tag(tag)) {
            #if os(macOS)
            Label {
                TextField(text: $tag.wrappedName) { tag.nameText }.badge(tag.bookmarksArray.count)
            } icon: {
                Image(systemName: "tag")
            }
            #else
            if editMode?.wrappedValue.isEditing == true {
                TextField(text: $tag.wrappedName) { tag.nameText }
            } else {
                Label {
                    tag.nameText.badge(tag.bookmarksArray.count)
                } icon: {
                    Image(systemName: "tag")
                }
            }
            #endif
        }
        .contentShape(Rectangle())
        .onDrop(
            of: [.denBookmark, .denItem],
            delegate: TagNavDropDelegate(context: viewContext, tag: tag)
        )
        .accessibilityIdentifier("TagNavLink")
        .contextMenu {
            DeleteTagButton(tag: tag)
        }
    }
}
