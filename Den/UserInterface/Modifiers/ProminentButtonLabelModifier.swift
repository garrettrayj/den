//
//  ProminentButtonLabelModifier.swift
//  Den
//
//  Created by Garrett Johnson on 4/24/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ProminentButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .labelStyle(.titleAndIcon)
            .buttonStyle(AccentButtonStyle())
    }
}
