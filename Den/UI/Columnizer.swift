//
//  Columnizer.swift
//  Den
//
//  Created by Garrett Johnson on 9/29/23.
//  Copyright © 2023 Garrett Johnson
//

import Foundation

struct Columnizer {
    static func calculateColumnCount(width: CGFloat, layoutScalingFactor: Double) -> Int {
        let adjustedWidth = width / layoutScalingFactor

        return max(1, Int((adjustedWidth / log2(adjustedWidth)) / 32))
    }

    static func columnize<T: Identifiable>(columnCount: Int, list: [T]) -> [(Int, [T])] {
        var columnData: [(Int, [T])] = []

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
