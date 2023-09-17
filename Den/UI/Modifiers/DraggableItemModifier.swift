//
//  DraggableItemModifier.swift
//  Den
//
//  Created by Garrett Johnson on 9/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DraggableItemModifier: ViewModifier {
    @ObservedObject var item: Item

    func body(content: Content) -> some View {
        if let linkURL = item.link {
            content
                .contentShape(Rectangle())
                .draggable(
                    TransferableItem(
                        objectURI: item.objectID.uriRepresentation(),
                        linkURL: linkURL
                    )
                )
        } else {
            content
        }
    }
}
