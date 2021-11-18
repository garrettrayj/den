//
//  ToolbarButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        ToolbarButton(configuration: configuration)
    }

    private struct ToolbarButton: View {
        let configuration: ButtonStyle.Configuration

        @Environment(\.isEnabled) private var isEnabled: Bool
        var body: some View {

            #if targetEnvironment(macCatalyst)
            configuration.label
                .frame(minHeight: 40, alignment: .center)
                .foregroundColor(
                    isEnabled ?
                        configuration.isPressed ? Color.accentColor.opacity(0.32) : Color.accentColor
                        :
                        Color.secondary
                )
                .background(Color.clear)
                .padding(.leading, 16)
            #else
            configuration.label
                .padding(.horizontal, 12)
                .frame(minHeight: 40, alignment: .center)
                .foregroundColor(
                    isEnabled ?
                        configuration.isPressed ? Color.accentColor.opacity(0.32) : Color.accentColor
                        :
                        Color.secondary
                )
                .background(Color.clear)
            #endif

        }
    }
}
