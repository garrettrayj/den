//
//  AccentButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 7/11/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AccentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .labelStyle(.titleAndIcon)
            .font(.body.weight(.medium))
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                configuration.isPressed ?
                    Color.accentColor.brightness(-0.1) :
                    Color.accentColor.brightness(0)
            )
            .cornerRadius(8)
            .foregroundColor(
                isEnabled ?
                    configuration.isPressed ? .white.opacity(0.9) : .white
                    :
                    .white.opacity(0.6)
            )
    }
}
