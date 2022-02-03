//
//  AccentButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 7/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct AccentButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        AccentButton(configuration: configuration)
    }

    private struct AccentButton: View {
        let configuration: ButtonStyle.Configuration

        @Environment(\.isEnabled) private var isEnabled: Bool
        var body: some View {
            configuration.label
                .font(.title3)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(
                    configuration.isPressed ?
                        Color.accentColor.brightness(-0.1) :
                        Color.accentColor.brightness(0)
                )
                .cornerRadius(8)
                .foregroundColor(
                    isEnabled ?
                        configuration.isPressed ? Color.white.opacity(0.9) : Color.white
                        :
                        Color.white.opacity(0.6)
                )
        }
    }
}
