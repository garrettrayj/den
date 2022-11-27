//
//  ToolbarButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 9/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @State private var hovering: Bool = false

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            #if targetEnvironment(macCatalyst)
            .padding(.horizontal, 8)
            .frame(height: 28, alignment: .center)
            .fontWeight(.semibold)
            .foregroundColor(
                isEnabled ?
                    configuration.isPressed ? Color.primary : Color.secondary
                    :
                    Color(UIColor.tertiaryLabel)
            )
            .background(
                isEnabled ?
                    configuration.isPressed ?
                        Color(UIColor.systemFill)
                        :
                        hovering ?
                            Color(UIColor.quaternarySystemFill)
                            :
                            Color.clear
                    :
                    Color.clear
            )
            .cornerRadius(8)
            #else
            .frame(height: 44, alignment: .center)
            .foregroundColor(
                isEnabled ?
                    configuration.isPressed ?
                        Color.accentColor.opacity(0.5)
                        :
                        Color.accentColor
                    :
                    Color(UIColor.tertiaryLabel)
            )
            .background(Color.clear)
            #endif
            .onHover { hovered in
                hovering = hovered
            }
    }
}
