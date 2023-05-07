//
//  SecondaryGroupedHighlight.swift
//  Den
//
//  Created by Garrett Johnson on 5/6/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SecondaryGroupedHighlight: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Rectangle().fill(.thinMaterial).background(.quaternary)
    }
}
