//
//  TrendItem.swift
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

@Model 
class TrendItem {
    var id: UUID?
    var item: Item?
    var trend: Trend?
    
    init(
        id: UUID? = nil,
        item: Item? = nil,
        trend: Trend? = nil
    ) {
        self.id = id
        self.item = item
        self.trend = trend
    }
    
    static func create(
        in modelContext: ModelContext,
        trend: Trend,
        item: Item
    ) -> TrendItem {
        let trendItem = TrendItem()
        trendItem.id = UUID()
        trendItem.trend = trend
        trendItem.item = item
        
        modelContext.insert(trendItem)

        return trendItem
    }
}
