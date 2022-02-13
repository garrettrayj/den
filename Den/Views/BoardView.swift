//
//  BoardView.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BoardView<Content: View, T: Identifiable>: View where T: Hashable {
    var content: (T) -> Content
    var list: [T]
    var spacing: CGFloat
    var width: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            ForEach(columnData, id: \.self) { columnObjects in
                LazyVStack(alignment: .center, spacing: spacing) {
                    ForEach(columnObjects) { object in
                        content(object)
                    }
                }
            }
        }
    }

    init(spacing: CGFloat = 16, width: CGFloat, list: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.spacing = spacing
        self.width = width
        self.list = list
        self.content = content
    }

    private var columnData: [[T]] {
        let columns: Int = max(1, Int((width / log2(width)) / 30))
        var gridArray: [[T]] = Array(repeating: [], count: columns)
        var currentIndex: Int = 0

        for object in list {
            gridArray[currentIndex].append(object)

            if currentIndex == (columns - 1) {
                currentIndex = 0
            } else {
                currentIndex += 1
            }
        }

        return gridArray
    }
}
