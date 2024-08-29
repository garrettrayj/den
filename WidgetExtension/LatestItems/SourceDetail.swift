//
//  SourceDetail.swift
//  Widget Extension
//
//  Created by Garrett Johnson on 5/1/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import AppIntents
import CoreData
import SwiftUI

struct SourceDetail: AppEntity {
    let id: String
    let entityType: NSManagedObject.Type?
    let title: String
    let symbol: String?

    static let typeDisplayRepresentation: TypeDisplayRepresentation = .init(
        name: .init("Source", comment: "Widget configuration option label.")
    )
    static let defaultQuery = SourceQuery()

    var displayRepresentation: DisplayRepresentation {
        if entityType == Page.self {
            DisplayRepresentation(
                title: .init(stringLiteral: title),
                subtitle: .init(
                    "Folder",
                    comment: "Latest items widget folder source type subtitle."
                ),
                image: {
                    if let symbol = symbol {
                        return .init(systemName: symbol)
                    } else {
                        return nil
                    }
                }()
            )
        } else if entityType == Feed.self {
            DisplayRepresentation(
                title: .init(stringLiteral: title),
                image: .init(systemName: "dot.radiowaves.up.forward")
            )
        } else {
            DisplayRepresentation(
                title: .init("Inbox", comment: "Latest items widget source title."),
                subtitle: .init("All Feeds", comment: "Latest items widget Inbox source subtitle."),
                image: .init(systemName: "tray")
            )
        }
    }
}
