//
//  ToolbarButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 1/29/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        ToolbarButton(configuration: configuration)
    }

    private struct ToolbarButton: View {
        @Environment(\.isEnabled) private var isEnabled: Bool

        let configuration: ButtonStyle.Configuration

        var body: some View {
            configuration.label
                .font(.body.weight(.medium))
                .frame(height: 32)
                .padding(.horizontal, 4)
                .foregroundColor(
                    isEnabled ?
                        configuration.isPressed ? Color.accentColor.opacity(0.5) : Color.accentColor
                        :
                        Color.secondary
                )
                .cornerRadius(6)
        }
    }
}
