//
//  StartRowModifier.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson
//

import SwiftUI

struct StartRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            #if targetEnvironment(macCatalyst)
            .font(.title3)
            .padding(.vertical, 8)
            #endif
    }
}
