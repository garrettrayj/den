//
//  ItemTags.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemTags: View {
    @ObservedObject var item: Item

    var body: some View {
        bookmarksList.font(.caption2).imageScale(.small)
    }

    var bookmarksList: Text {
        var text = Text("")
        for bookmark in item.bookmarks {
            guard let tagName = bookmark.tag?.nameText else { continue }
            text = text + Text("\(Image(systemName: "tag"))\u{00A0}") + tagName + Text("  ")
        }

        return text
    }
}
