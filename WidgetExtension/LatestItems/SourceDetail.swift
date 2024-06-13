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

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Source"
    static let defaultQuery = SourceQuery()
            
    var displayRepresentation: DisplayRepresentation {
        if entityType == Page.self {
            if let symbol = symbol {
                DisplayRepresentation(
                    title: "\(title)",
                    subtitle: "Folder",
                    image: .init(systemName: symbol)
                )
            } else {
                DisplayRepresentation(
                    title: "\(title)",
                    subtitle: "Folder",
                    image: .init(systemName: "folder")
                )
            }
        } else if entityType == Feed.self {
            DisplayRepresentation(
                title: "\(title)",
                image: .init(systemName: "dot.radiowaves.up.forward")
            )
        } else {
            if let symbol = symbol {
                DisplayRepresentation(
                    title: "\(title)",
                    subtitle: "All Feeds",
                    image: .init(systemName: symbol)
                )
            } else {
                DisplayRepresentation(title: "\(title)", subtitle: "All Feeds")
            }
        }
    }
}
