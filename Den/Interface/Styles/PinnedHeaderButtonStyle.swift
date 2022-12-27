//
//  PinnedHeaderButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 12/26/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PinnedHeaderButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @State private var hovering: Bool = false

    var backgroundColor: Color = Color.clear

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundColor(
                isEnabled ? .primary : .secondary
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                backgroundColor.overlay {
                    isEnabled ?
                        hovering ? Color(UIColor.quaternarySystemFill) : .clear
                    : .clear
                }
            )
            .onHover { hovered in
                hovering = hovered
            }
            .onDisappear {
                hovering = false
            }
    }
}
