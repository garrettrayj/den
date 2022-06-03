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
            .frame(minHeight: 24)
            .listRowSeparator(.visible)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        #else
        content
        #endif
    }
}
