//
//  HoverShadowButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct HoverShadowButtonStyle: ButtonStyle {

    func makeBody(configuration: Self.Configuration) -> some View {
        HoverShadowButton(configuration: configuration)
    }

    private struct HoverShadowButton: View {
        @Environment(\.isEnabled) private var isEnabled: Bool

        let configuration: ButtonStyle.Configuration

        @State private var hovering: Bool = false

        var body: some View {
            configuration.label
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
        }
    }
}
