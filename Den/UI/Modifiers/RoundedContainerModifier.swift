//
//  RoundedContainerModifier.swift
//  Den
//
//  Created by Garrett Johnson on 3/7/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RoundedContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .topLeading)
            #if os(macOS)
            .background(.background.quinary)
            #else
            .background(Color(.secondarySystemGroupedBackground))
            #endif
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.125), radius: 4)
    }
}
