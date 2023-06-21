//
//  GroupedBackground.swift
//  Den
//
//  Created by Garrett Johnson on 4/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GroupedBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        #if os(iOS)
        if colorScheme == .dark {
            // Dark mode system background lightens when window is split with another.
            EmptyView()
        } else {
            Rectangle().fill(.thinMaterial).edgesIgnoringSafeArea(.all)
        }
        #else
        if colorScheme == .dark {
            Rectangle()
                .fill(.regularMaterial)
                .edgesIgnoringSafeArea(.all)
        } else {
            Rectangle()
                .fill(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
        }
        #endif
    }
}
