//
//  FeedTitleButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedTitleButtonStyle: ButtonStyle {
    var backgroundColor: Color = Color(UIColor.secondarySystemGroupedBackground)

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        FeedTitleButton(configuration: configuration, backgroundColor: backgroundColor)
    }

    private struct FeedTitleButton: View {
        @Environment(\.isEnabled) private var isEnabled: Bool
        @State private var hovering: Bool = false

        let configuration: ButtonStyle.Configuration
        let backgroundColor: Color

        var body: some View {
            configuration.label
                .font(.title3)
                .foregroundColor(
                    isEnabled ? .primary : .secondary
                )
                .frame(height: 40)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    isEnabled ?
                        hovering ? Color(UIColor.quaternarySystemFill) : backgroundColor
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
