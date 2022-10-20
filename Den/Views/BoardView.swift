//
//  BoardView.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BoardView<Content: View, T: Identifiable>: View where T: Hashable {
    let content: (T) -> Content
    let list: [T]
    let spacing: CGFloat
    let width: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            ForEach(columnData, id: \.0) { _, columnObjects in
                LazyVStack(alignment: .center, spacing: spacing) {
                    ForEach(columnObjects) { object in
                        content(object)
                    }
                }
            }
        }
    }

    init(spacing: CGFloat = 12, width: CGFloat, list: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.spacing = spacing
        self.width = width
        self.list = list
        self.content = content
    }

    private var columnData: [(Int, [T])] {
        let columns: Int = max(1, Int((width / log2(width)) / 30))
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
