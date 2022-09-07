//
//  ToolbarButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 9/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        ToolbarButton(configuration: configuration)
    }

    private struct ToolbarButton: View {
        let configuration: ButtonStyle.Configuration
        @State private var hovering: Bool = false

        @Environment(\.isEnabled) private var isEnabled: Bool

        var body: some View {
            configuration.label
                .fontWeight(.medium)
                .foregroundColor(
                    isEnabled ?
                    configuration.isPressed ? Color.primary : Color.secondary
                        :
                        Color(UIColor.tertiaryLabel)
                )
                .frame(height: 28, alignment: .center)
                .padding(.horizontal, 6)
                .background(
                    isEnabled ?
                        configuration.isPressed ?
                            Color(UIColor.systemFill) :
                                hovering ? Color(UIColor.tertiarySystemFill) : Color.clear
                    : Color.clear
                )
                .cornerRadius(6)
                .onHover { hovered in
                    hovering = hovered
                }
        }
    }
}
