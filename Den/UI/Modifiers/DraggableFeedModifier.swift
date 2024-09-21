//
//  DraggableFeedModifier.swift
//  Den
//
//  Created by Garrett Johnson on 9/16/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct DraggableFeedModifier: ViewModifier {
    let feed: Feed

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .draggable(TransferableFeed(objectURI: feed.objectID.uriRepresentation()))
    }
}
