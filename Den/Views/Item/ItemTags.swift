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

    // swiftlint:disable shorthand_operator
    private var bookmarksList: Text {
        let prefix = Text(Image(systemName: "tag")) + Text(verbatim: "\u{00A0}")
        
        var tagLabels = item.bookmarks.compactMap {
            $0.tag?.displayName
        }.map { displayName in
            prefix + displayName
        }
        
        var output = Text("")
        
        for (idx, label) in tagLabels.enumerated() {
            if idx > 0 {
                output = output + Text(
                    verbatim: "\(NSLocale.autoupdatingCurrent.groupingSeparator ?? ",") "
                )
            }
            
            output = output + label
        }

        return output
    }
    // swiftlint:enable shorthand_operator
}
