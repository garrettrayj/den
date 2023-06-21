//
//  QuaternaryGroupedBackground.swift
//  Den
//
//  Created by Garrett Johnson on 4/30/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct QuaternaryGroupedBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Rectangle().fill(.quaternary.opacity(0.5))
    }
}
