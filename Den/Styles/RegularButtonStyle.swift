//
//  RegularButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 1/15/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct RegularButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        RegularButton(configuration: configuration)
    }

    private struct RegularButton: View {
        let configuration: ButtonStyle.Configuration

        @Environment(\.isEnabled) private var isEnabled: Bool
        var body: some View {
            configuration.label
                .font(.body)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .foregroundColor(
                    isEnabled ?
                        configuration.isPressed ? Color.accentColor.opacity(0.9) : Color.accentColor
                        :
                        Color.secondary
                )
        }
    }
}
