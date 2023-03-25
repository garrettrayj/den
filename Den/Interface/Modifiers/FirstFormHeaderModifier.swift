//
//  FirstFormHeaderModifier.swift
//  Den
//
//  Created by Garrett Johnson on 10/1/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FirstFormHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            #if targetEnvironment(macCatalyst)
            .listRowInsets(EdgeInsets(top: 24, leading: 16, bottom: 8, trailing: 16))
            #endif
    }
}
