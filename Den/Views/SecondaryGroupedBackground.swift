//
//  SecondaryGroupedBackground.swift
//  Den
//
//  Created by Garrett Johnson on 4/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SecondaryGroupedBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var highlight = false

    var body: some View {
        if colorScheme == .dark {
            if highlight {
                Rectangle()
                    .fill(.regularMaterial)
                    .background(.tertiary)
            } else {
                Rectangle()
                    .fill(.ultraThickMaterial)
                    .background(.quaternary)
            }
        } else {
            if highlight {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .background(.background)
            } else {
                Rectangle().fill(.background)
            }
        }
    }
}
