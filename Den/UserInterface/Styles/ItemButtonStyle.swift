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
        let configuration: ButtonStyle.Configuration
        let read: Bool

        @State private var hovering: Bool = false

        var body: some View {
            configuration.label
                .font(.headline)
                .foregroundColor(read ? .secondary : .primary)
                .frame(maxWidth: .infinity)
                .background(
                    hovering ?
                        Color(UIColor.quaternarySystemFill) :
                        Color(UIColor.secondarySystemGroupedBackground))
                .onHover { hovered in
                    hovering = hovered
                }
        }
    }
}
