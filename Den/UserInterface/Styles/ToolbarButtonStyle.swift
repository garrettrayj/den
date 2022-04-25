//
//  ToolbarButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 1/29/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {
    var inBottomBar = false
    var isBackButton = false

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        ToolbarButton(
            configuration: configuration,
            inBottomBar: inBottomBar
        )
    }

    private struct ToolbarButton: View {
        @Environment(\.isEnabled) private var isEnabled: Bool

        let configuration: ButtonStyle.Configuration
        let inBottomBar: Bool

        var body: some View {
            configuration.label
                .foregroundColor(
                    isEnabled ?
                        configuration.isPressed ? Color.accentColor.opacity(0.5) : Color.accentColor
                        :
                        Color.secondary
                )
                #if targetEnvironment(macCatalyst)
                .padding(.top, inBottomBar ? 0 : -4)
                #endif
        }
    }
}
