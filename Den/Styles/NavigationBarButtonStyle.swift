//
//  NavigationBarButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NavigationBarButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        NavigationBarButton(configuration: configuration)
    }

    private struct NavigationBarButton: View {
        @Environment(\.isEnabled) private var isEnabled: Bool

        let configuration: ButtonStyle.Configuration

        var body: some View {
            configuration.label
                .frame(minHeight: 40, alignment: .center)
                .foregroundColor(
                    isEnabled ?
                        configuration.isPressed ? Color.accentColor.opacity(0.32) : Color.accentColor
                        :
                        Color.secondary
                )
                .background(Color.clear)
                .padding(.leading, 12)
        }
    }
}
