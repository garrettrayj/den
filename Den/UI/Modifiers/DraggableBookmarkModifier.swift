//
//  DraggableBookmarkModifier.swift
//  Den
//
//  Created by Garrett Johnson on 9/16/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct DraggableBookmarkModifier: ViewModifier {
    let bookmark: Bookmark

    func body(content: Content) -> some View {
        if let linkURL = bookmark.link {
            content
                .contentShape(Rectangle())
                .draggable(
                    TransferableBookmark(
                        objectURI: bookmark.objectID.uriRepresentation(),
                        linkURL: linkURL
                    )
                )
        } else {
            content
        }
    }
}
