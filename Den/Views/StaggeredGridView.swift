//
//  StaggeredGridView.swift
//  Den
//
//  Created by Garrett Johnson on 10/27/21.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct StaggeredGridView<Content: View, T: Identifiable>: View where T: Hashable {
    var content: (T) -> Content
    var list: [T]
    var spacing: CGFloat

    var body: some View {
        AxisGeometryReader(axis: .horizontal, alignment: .leading) { width in
            HStack(alignment: .top, spacing: 16) {
                ForEach(generateColumns(width: width), id: \.self) { columnObjects in
                    // For Optimized Using LazyStack...
                    LazyVStack(spacing: spacing) {
                        ForEach(columnObjects) { object in
                            content(object).frame(minWidth: 200, maxWidth: 400)
                        }
                    }
                }
            }
            .frame(minWidth: 272)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 64)
        }
    }

    init(spacing: CGFloat = 16, list: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.content = content
        self.list = list
        self.spacing = spacing
    }

    private func generateColumns(width: CGFloat) -> [[T]] {
        let columns: Int = dynamicColumnCount(width: width)
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

    private func dynamicColumnCount(width: CGFloat) -> Int {
        if width > 1500 {
            return 5
        }

        if width > 1200 {
            return 4
        }

        if width > 800 {
            return 3
        }

        if width > 500 {
            return 2
        }

        return 1
    }
}
