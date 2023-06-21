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

    var body: some View {
        #if os(macOS)
        Rectangle().fill(Color(.textBackgroundColor))
        #else
        Rectangle().fill(Color(.secondarySystemGroupedBackground))
        #endif
    }
}
