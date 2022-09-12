//
//  ItemLinkButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 5/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemButtonStyle: ButtonStyle {
    let read: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        ItemButton(configuration: configuration, read: read)
    }

    private struct ItemButton: View {
        @Environment(\.isEnabled) private var isEnabled: Bool

        let configuration: ButtonStyle.Configuration
        let read: Bool

        @State private var hovering: Bool = false

        var body: some View {
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
}
