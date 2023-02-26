//
//  FormRowModifier.swift
//  Den
//
//  Created by Garrett Johnson on 11/14/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FormRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if targetEnvironment(macCatalyst)
        content.padding(.vertical, 8).frame(minHeight: 36)
        #else
        content.padding(.vertical, 4)
        #endif
    }
}
