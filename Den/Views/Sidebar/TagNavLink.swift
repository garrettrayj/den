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
    
    @Binding var detailPanel: DetailPanel?

    var body: some View {
        Group {
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
                Button {
                    detailPanel = .tag(tag)
                } label: {
                    Label {
                        tag.nameText.badge(tag.bookmarksArray.count)
                    } icon: {
                        Image(systemName: "tag")
                    }
                }
            }
            #endif
        }
        .lineLimit(1)
        .tag(DetailPanel.tag(tag))
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
