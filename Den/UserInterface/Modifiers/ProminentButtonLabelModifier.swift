//
//  ProminentButtonLabelModifier.swift
//  Den
//
//  Created by Garrett Johnson on 4/24/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ProminentButtonModifier: ViewModifier {
    @Environment(\.dismiss) var dismiss

    var title: String = "Back"

    func body(content: Content) -> some View {
        content
        #if targetEnvironment(macCatalyst)
            .buttonStyle(AccentButtonStyle())
        #else
            .buttonStyle(BorderedProminentButtonStyle())
        #endif
    }
}
