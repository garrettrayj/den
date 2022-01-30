//
//  ToolbarButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 1/29/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .frame(height: 32)
            .padding(.horizontal, 6)
            .foregroundColor(
                isEnabled ?
                    configuration.isPressed ? Color.accentColor.opacity(0.5) : Color.accentColor
                    :
                    Color.secondary
            )
            .cornerRadius(6)
    }
}
