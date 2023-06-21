//
//  TertiaryGroupedHighlight.swift
//  Den
//
//  Created by Garrett Johnson on 5/7/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TertiaryGroupedHighlight: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Rectangle().fill(.regularMaterial).overlay(.quaternary)
    }
}
