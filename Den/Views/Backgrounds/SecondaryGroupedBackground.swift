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
        #if os(macOS)
        Rectangle().fill(.background)
        #else
        if colorScheme == .dark {
            Rectangle().fill(Color(.secondarySystemGroupedBackground))
        } else {
            Rectangle().fill(.background)
        }
        #endif
    }
}
