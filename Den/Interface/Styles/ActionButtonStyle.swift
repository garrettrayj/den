//
//  ActionButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .labelStyle(.titleAndIcon)
            .imageScale(.large)
            .font(.body.weight(.semibold))
            .foregroundColor(
                isEnabled ?
                    configuration.isPressed ? Color.accentColor.opacity(0.5) : Color.accentColor
                    :
                    Color(UIColor.tertiaryLabel)
            )
            .contentShape(Rectangle())
    }
}
