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
    let width: CGFloat
    let list: [T]

    @ViewBuilder let content: (T) -> Content
    
    @ScaledMetric private var idealColumnWidth = Columnizer.idealColumnWidth

    var body: some View {
        HStack(alignment: .top) {
            ForEach(
                Columnizer.columnize(
                    columnCount: Int(width / idealColumnWidth),
                    list: list
                ),
                id: \.0
            ) { _, columnObjects in
                LazyVStack {
                    ForEach(columnObjects) { object in
                        content(object)
                    }
                }
            }
        }
        .padding()
    }
}
