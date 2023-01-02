//
//  FormFirstHeaderModifier.swift
//  Den
//
//  Created by Garrett Johnson on 10/1/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct FormFirstHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            #if targetEnvironment(macCatalyst)
            .listRowInsets(EdgeInsets(top: 28, leading: 16, bottom: 8, trailing: 16))
            #endif
    }
}
