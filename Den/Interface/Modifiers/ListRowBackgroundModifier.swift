//
//  ListRowBackgroundModifier.swift
//  Den
//
//  Created by Garrett Johnson on 3/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ListRowBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .listRowBackground(
                Rectangle()
                    #if targetEnvironment(macCatalyst)
                    .fill(.clear)
                    .background(.bar)
                    .background(.background)
                    #else
                    .fill(Color(.secondarySystemGroupedBackground))
                    #endif
            )
    }
}
