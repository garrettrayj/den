//
//  TrailingToolbarItemModifier.swift
//  Den
//
//  Created by Garrett Johnson on 2/20/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrailingToolbarItemModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            #if targetEnvironment(macCatalyst)
            .padding(.trailing, 4)
            #else
            .padding(.trailing, 8)
            #endif
    }
}
