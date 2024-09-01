//
//  Columnizer.swift
//  Den
//
//  Created by Garrett Johnson on 9/29/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import Foundation

struct Columnizer {
    static let idealColumnWidth: CGFloat = 320

    static func columnize<T: Identifiable>(columnCount: Int, list: [T]) -> [(Int, [T])] {
        var columnData: [(Int, [T])] = []
        
        let columnCount = max(1, columnCount)

        // Setup empty columns
        for columnIndex in 0...columnCount - 1 {
            columnData.append((columnIndex, []))
        }

        // Populate the data array
        var currentColumn = 0
        for object in list {
            columnData[currentColumn].1.append(object)

            if currentColumn == (columnCount - 1) {
                currentColumn = 0
            } else {
                currentColumn += 1
            }
        }

        return columnData
    }
}
