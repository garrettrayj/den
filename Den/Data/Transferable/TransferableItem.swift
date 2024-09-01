//
//  TransferableItem.swift
//  Den
//
//  Created by Garrett Johnson on 9/16/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct TransferableItem: Codable, Transferable {
    var objectURI: URL
    var linkURL: URL

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .denItem)
        ProxyRepresentation(exporting: \.linkURL)
        ProxyRepresentation(exporting: \.linkURL.absoluteString)
    }
}

extension UTType {
    static let denItem = UTType(exportedAs: "net.devsci.den.transferable.item")
}
