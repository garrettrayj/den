//
//  ItemLinkButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 5/29/20.
//  Copyright © 2020 Garrett Johnson
//

import SwiftUI

struct ItemButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    let read: Bool

    @State private var hovering: Bool = false

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(
                isEnabled ?
                    read ? .secondary : .primary
                :
                    read ? Color(UIColor.quaternaryLabel) : Color(UIColor.tertiaryLabel)
            )
            .frame(maxWidth: .infinity)
            .background(
                isEnabled ?
                    hovering ?
                        Color(UIColor.quaternarySystemFill) :
                        Color(UIColor.secondarySystemGroupedBackground)
                : Color.clear
            )
            .onHover { hovered in
                hovering = hovered
            }
            .onDisappear {
                hovering = false
            }
    }
}
