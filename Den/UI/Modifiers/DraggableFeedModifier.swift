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

    @State private var isHovered = false

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
                .onHover { hovering in
                    isHovered = hovering
                }
                .shadow(
                    color: isHovered ? .black.opacity(0.125) : .clear,
                    radius: 3,
                    x: 1,
                    y: 1
                )
        } else {
            content
        }
    }
}
