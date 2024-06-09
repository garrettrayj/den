//
//  DraggableBookmarkModifier.swift
//  Den
//
//  Created by Garrett Johnson on 9/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DraggableBookmarkModifier: ViewModifier {
    @Bindable var bookmark: Bookmark

    func body(content: Content) -> some View {
        if let linkURL = bookmark.link {
            content
                .contentShape(Rectangle())
                .draggable(
                    TransferableBookmark(
                        persistentModelID: bookmark.persistentModelID,
                        linkURL: linkURL
                    )
                )
        } else {
            content
        }
    }
}
