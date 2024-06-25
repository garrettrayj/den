//
//  DraggableFeedModifier.swift
//  Den
//
//  Created by Garrett Johnson on 9/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DraggableFeedModifier: ViewModifier {
    @Bindable var feed: Feed

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .draggable(TransferableFeed(persistentModelID: feed.persistentModelID))
    }
}
