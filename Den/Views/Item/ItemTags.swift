//
//  ItemTags.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ItemTags: View {
    @ObservedObject var item: Item

    var body: some View {
        bookmarksList.font(.caption2).imageScale(.small)
    }

    private var bookmarksList: Text {
        var tagNames = item.bookmarks.compactMap { $0.tag?.displayName }
        let prefix = Text(Image(systemName: "tag")) + Text(verbatim: "\u{00A0}")
        let firstTag = prefix + tagNames.removeFirst()

        return tagNames.reduce(firstTag) { partialResult, tagName in
            partialResult +
            Text(verbatim: "\(NSLocale.autoupdatingCurrent.groupingSeparator ?? ",") ") +
            prefix + tagName
        }
    }
}
