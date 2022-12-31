//
//  PlainToolbarButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 12/26/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PlainToolbarButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    @State private var hovering: Bool = false

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            #if targetEnvironment(macCatalyst)
            .fontWeight(.semibold)
            .foregroundColor(
                isEnabled ?
                    configuration.isPressed ?
                        Color.secondary.opacity(0.5)
                        :
                        hovering ?
                            Color.secondary.opacity(0.75)
                            :
                            Color.secondary
                    :
                    Color(UIColor.tertiaryLabel)
            )
            #else
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
            .frame(height: 44, alignment: .center)
            .onHover { hovered in
                hovering = hovered
            }
            .contentShape(Rectangle())
    }
}

