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
        #if targetEnvironment(macCatalyst)
        if colorScheme == .dark {
            Rectangle()
                .fill(.thinMaterial)
                .background(.background)
                .edgesIgnoringSafeArea(.all)
        } else {
            Rectangle()
                .fill(.thinMaterial)
                .background(.background)
                .edgesIgnoringSafeArea(.all)
        }
        #else
        if colorScheme == .dark {
            Rectangle()
                .fill(Color(.systemGroupedBackground))
                .edgesIgnoringSafeArea(.all)
        } else {
            Rectangle()
                .fill(Color(.systemGroupedBackground))
                .edgesIgnoringSafeArea(.all)
        }
        #endif
    }
}
