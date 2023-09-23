//
//  NullSymbol.swift
//  Den
//
//  Created by Garrett Johnson on 9/23/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NullSymbol: View {
    var body: some View {
        Image(systemName: "circle.slash").rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
}
