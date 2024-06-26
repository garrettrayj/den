//
//  Trend.swift
//  Den
//
//  Created by Garrett Johnson on 6/5/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//
//

import Foundation
import SwiftData
import SwiftUI

@Model 
class Trend {
    var id: UUID?
    var profileId: UUID?
    var read: Bool?
    var slug: String?
    var tag: String?
    var title: String?
    var items: [Item]?
    
    init(
        id: UUID? = nil,
        profileId: UUID? = nil,
        read: Bool? = nil,
        slug: String? = nil,
        tag: String? = nil,
        title: String? = nil,
        items: [Item]? = nil
    ) {
        self.id = id
        self.profileId = profileId
        self.read = read
        self.slug = slug
        self.tag = tag
        self.title = title
        self.items = items
    }
    
    var titleText: Text {
        if let title = title {
            return Text(title)
        } else {
            return Text("Untitled", comment: "Default trend title.")
        }
    }
    
    var feeds: [Feed] {
        Set(items?.compactMap { $0.feedData?.feed } ?? []).sorted { $0.wrappedTitle < $1.wrappedTitle }
    }
    
    func updateReadStatus() {
        read = items?.unread.isEmpty
    }

    static func create(in modelContext: ModelContext) -> Trend {
        let trend = Trend()
        trend.id = UUID()
        trend.items = []

        modelContext.insert(trend)

        return trend
    }
}

extension Collection where Element == Trend {
    var containingUnread: [Trend] {
        self.filter { !($0.read ?? false) }
    }
    
    var items: [Item] {
        return self.flatMap { $0.items ?? [] }.uniqueElements()
    }
}
