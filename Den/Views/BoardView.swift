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

    var body: some View {
        AxisGeometryReader(axis: .horizontal, alignment: .center) { width in
            HStack(alignment: .top, spacing: spacing) {
                ForEach(generateColumns(width: width), id: \.self) { columnObjects in
                    LazyVStack(alignment: .center, spacing: spacing) {
                        ForEach(columnObjects) { object in
                            content(object)
                        }
                    }
                }
            }
        }
    }

    init(spacing: CGFloat = 16, list: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.spacing = spacing
        self.list = list
        self.content = content
    }

    private func generateColumns(width: CGFloat) -> [[T]] {
        let columns: Int = max(1, Int(width / 300))
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
