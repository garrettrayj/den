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
        #if targetEnvironment(macCatalyst)
        if colorScheme == .dark {
            if highlight {
                Rectangle()
                    .fill(.thinMaterial)
                    .background(.tertiary)
            } else {
                Rectangle()
                    .fill(.quaternary)
            }
        } else {
            if highlight {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .background(Color(.secondarySystemGroupedBackground))
            } else {
                Rectangle().fill(Color(.secondarySystemGroupedBackground))
            }
        }
        #else
        if colorScheme == .dark {
            if highlight {
                Rectangle()
                    .fill(.thinMaterial)
                    .background(.tertiary)
            } else {
                Rectangle()
                    .fill(Color(.secondarySystemGroupedBackground))
            }
        } else {
            if highlight {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .background(Color(.secondarySystemGroupedBackground))
            } else {
                Rectangle()
                    .fill(Color(.secondarySystemGroupedBackground))
            }
        }
        #endif
    }
}
