//
//  ActionButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 4/24/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        ActionButton(configuration: configuration)
    }

    private struct ActionButton: View {
        let configuration: ButtonStyle.Configuration

        @Environment(\.isEnabled) private var isEnabled: Bool
        var body: some View {
            configuration.label
                .foregroundColor(isEnabled ? Color.accentColor : Color.secondary)
                .opacity(configuration.isPressed ? 0.6 : 1.0)
        }
    }
}
