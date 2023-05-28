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

    let content: (T) -> Content
    let list: [T]
    let geometry: GeometryProxy
    let lazy: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ForEach(columnData, id: \.0) { _, columnObjects in
                if lazy {
                    LazyVStack(alignment: .center, spacing: 12) {
                        ForEach(columnObjects) { object in
                            content(object)
                        }
                    }
                } else {
                    VStack(alignment: .center, spacing: 12) {
                        ForEach(columnObjects) { object in
                            content(object)
                        }
                    }.frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
    }

    init(geometry: GeometryProxy, list: [T], lazy: Bool = true, @ViewBuilder content: @escaping (T) -> Content) {
        self.geometry = geometry
        self.list = list
        self.content = content
        self.lazy = lazy
    }

    private var columnData: [(Int, [T])] {
        let adjustedWidth = geometry.size.width / dynamicTypeSize.layoutScalingFactor
        let columns: Int = max(1, Int((adjustedWidth / log2(adjustedWidth)) / 27.2))
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
