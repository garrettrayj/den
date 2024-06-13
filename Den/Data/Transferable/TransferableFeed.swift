//
//  TransferrableFeed.swift
//  Den
//
//  Created by Garrett Johnson on 8/29/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct TransferableFeed: Codable, Transferable {
    var persistentModelID: PersistentIdentifier

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .denFeed)
    }
}

extension UTType {
    static let denFeed = UTType(exportedAs: "net.devsci.den.transferable.feed")
}
