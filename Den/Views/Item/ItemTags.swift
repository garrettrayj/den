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
    @Bindable var item: Item
    
    static let separator = NSLocale.autoupdatingCurrent.groupingSeparator ?? ","

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "tag")
            tagNames
        }
        .font(.caption)
        .imageScale(.small)
        .lineLimit(2)
    }

    private var tagNames: Text {
        let tagNames = item.bookmarkTags.compactMap {
            $0.displayName
        }
        
        var output = Text(verbatim: "")
        
        // swiftlint:disable shorthand_operator
        for (idx, tagName) in tagNames.enumerated() {
            if idx > 0 {
                output = output + Text(verbatim: "\(ItemTags.separator) ")
            }
            
            output = output + tagName
        }
        // swiftlint:enable shorthand_operator

        return output
    }
}
