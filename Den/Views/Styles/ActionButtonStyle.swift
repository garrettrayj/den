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

    struct ActionButton: View {
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
