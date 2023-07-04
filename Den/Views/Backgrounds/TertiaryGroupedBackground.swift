//
//  TertiaryGroupedBackground.swift
//  Den
//
//  Created by Garrett Johnson on 4/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TertiaryGroupedBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Rectangle().fill(.regularMaterial)
    }
}
