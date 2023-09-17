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
    @ObservedObject var feed: Feed

    func body(content: Content) -> some View {
        if let feedURL = feed.url {
            content
                .contentShape(Rectangle())
                .draggable(
                    TransferableFeed(
                        objectURI: feed.objectID.uriRepresentation(),
                        feedURL: feedURL
                    )
                )
        } else {
            content
        }
    }
}
