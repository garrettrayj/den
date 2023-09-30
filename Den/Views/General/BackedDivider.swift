//
//  BackedDivider.swift
//  Den
//
//  Created by Garrett Johnson on 9/28/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BackedDivider: View {
    var body: some View {
        Divider()
            #if os(macOS)
            .background(.background)
            #else
            .background(Color(.secondarySystemGroupedBackground))
            #endif
    }
}
