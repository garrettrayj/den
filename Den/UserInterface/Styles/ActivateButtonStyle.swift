//
//  ActivateButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 1/28/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ActivateButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        ActivateButton(configuration: configuration)
    }

    private struct ActivateButton: View {
        let configuration: ButtonStyle.Configuration

        @Environment(\.isEnabled) private var isEnabled: Bool

        var body: some View {
            configuration.label
                .foregroundColor(
                    isEnabled ?
                        configuration.isPressed ? Color.green.opacity(0.5) : Color.green
                        :
                        Color.secondary
                )
        }
    }
}
