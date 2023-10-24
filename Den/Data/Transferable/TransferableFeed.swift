//
//  TransferrableFeed.swift
//  Den
//
//  Created by Garrett Johnson on 8/29/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI
import UniformTypeIdentifiers

struct TransferableFeed: Codable, Transferable {
    var objectURI: URL
    var feedURL: URL

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .denFeed)
        ProxyRepresentation(exporting: \.feedURL)
        ProxyRepresentation(exporting: \.feedURL.absoluteString)
    }
}

extension UTType {
    static var denFeed = UTType(exportedAs: "net.devsci.den.transferable.feed")
}
