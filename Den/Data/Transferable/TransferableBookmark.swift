//
//  TransferableBookmark.swift
//  Den
//
//  Created by Garrett Johnson on 9/16/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct TransferableBookmark: Codable, Transferable {
    let objectURI: URL
    let linkURL: URL

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .denBookmark)
        ProxyRepresentation(exporting: \.linkURL)
        ProxyRepresentation(exporting: \.linkURL.absoluteString)
    }
}

extension UTType {
    static let denBookmark = UTType(exportedAs: "net.devsci.den.transferable.bookmark")
}
