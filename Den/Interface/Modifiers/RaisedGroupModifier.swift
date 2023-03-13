//
//  RaisedGroupModifier.swift
//  Den
//
//  Created by Garrett Johnson on 3/7/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RaisedGroupModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            #if targetEnvironment(macCatalyst)
            .background(.bar)
            #else
            .background(Color(.secondarySystemGroupedBackground))
            #endif
            .cornerRadius(8)
            .shadow(
                color: .black.opacity(colorScheme == .light ? 0.15 : 0.5),
                radius: 1
            )
    }
}
