//
//  ToolbarButtonModifier.swift
//  Den
//
//  Created by Garrett Johnson on 9/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ToolbarButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            #if targetEnvironment(macCatalyst)
            .buttonStyle(ToolbarButtonStyle())
            #else
            .fontWeight(.medium)
            #endif
    }
}
