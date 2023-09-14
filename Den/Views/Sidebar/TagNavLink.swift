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
        .accessibilityIdentifier("TagNavLink")
        .tag(DetailPanel.tag(tag))
    }
}
