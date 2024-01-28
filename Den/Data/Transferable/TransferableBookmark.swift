//
//  TransferableBookmark.swift
//  Den
//
//  Created by Garrett Johnson on 9/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI
import UniformTypeIdentifiers

struct TransferableBookmark: Codable, Transferable {
    var objectURI: URL
    var linkURL: URL

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .denBookmark)
        ProxyRepresentation(exporting: \.linkURL)
        ProxyRepresentation(exporting: \.linkURL.absoluteString)
    }
}

extension UTType {
    static var denBookmark = UTType(exportedAs: "net.devsci.den.transferable.bookmark")
}
