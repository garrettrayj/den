//
//  FormRowModifier.swift
//  Den
//
//  Created by Garrett Johnson on 11/14/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FormRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if targetEnvironment(macCatalyst)
        content
            .frame(minHeight: 32)
        #else
        content
        #endif
    }
}
