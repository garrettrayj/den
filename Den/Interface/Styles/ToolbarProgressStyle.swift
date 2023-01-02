//
//  NavigationBarProgressStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/11/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

/**
 Indederminate circular ProgressViewStyle for use in place of toolbar buttons.
 */
struct ToolbarProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration).progressViewStyle(CircularProgressViewStyle())
            #if targetEnvironment(macCatalyst)
            .frame(width: 40, alignment: .center)
            #else
            .scaleEffect(1.2)
            #endif
    }
}
