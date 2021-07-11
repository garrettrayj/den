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
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color.accentColor)
                .cornerRadius(8)
                .font(.title3)
                .foregroundColor(isEnabled ? Color(UIColor.white) : Color(UIColor.white).opacity(0.5))
                .opacity(configuration.isPressed ? 0.8 : 1.0)
        }
    }
}
