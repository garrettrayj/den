//
//  TransferrableFeed.swift
//  Den
//
//  Created by Garrett Johnson on 8/29/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import UniformTypeIdentifiers

struct TransferableFeed: Codable, Transferable {
    var objectURI: URL
    var feedURLString: String

    init(feed: Feed) {
        self.objectURI = feed.objectID.uriRepresentation()
        self.feedURLString = feed.url?.absoluteString ?? ""
    }

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .feed)

        // Exporting a URL here causes error:
        // "Sandbox extension data required immediately for flavor public.file-url..."
        // Drag-n-drop works most of the time despite the error, but not always.
        // Semi-consistently, the first draggable in a view fails to drop.
        ProxyRepresentation(exporting: \.feedURLString)
    }
}

extension UTType {
    static var feed = UTType(exportedAs: "net.devsci.den.transferable.feed")
}
