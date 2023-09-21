//
//  BoardView.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BoardView<Content: View, T: Identifiable>: View where T: Hashable {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let width: CGFloat
    let list: [T]

    @ViewBuilder let content: (T) -> Content

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            ForEach(columnData, id: \.0) { _, columnObjects in
                LazyVStack(spacing: 8) {
                    ForEach(columnObjects) { object in
                        content(object)
                    }
                }
            }
        }
        .padding()
    }

    private var columnData: [(Int, [T])] {
        let adjustedWidth = width / dynamicTypeSize.layoutScalingFactor
        let columns: Int = max(1, Int((adjustedWidth / log2(adjustedWidth)) / 30))
        var gridArray: [(Int, [T])] = []

        var currentCol: Int = 0
        while currentCol < columns {
            gridArray.append((currentCol, []))
            currentCol += 1
        }

        var currentIndex: Int = 0
        for object in list {
            gridArray[currentIndex].1.append(object)

            if currentIndex == (columns - 1) {
                currentIndex = 0
            } else {
                currentIndex += 1
            }
        }

        return gridArray
    }
}
