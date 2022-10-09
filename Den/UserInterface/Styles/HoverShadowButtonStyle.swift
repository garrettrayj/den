//
//  HoverShadowButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct HoverShadowButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    @State private var hovering: Bool = false

    func makeBody(configuration: Self.Configuration) -> some View {
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
            .onDisappear {
                hovering = false
            }
    }
}
