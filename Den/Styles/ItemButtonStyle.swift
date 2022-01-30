//
//  ItemLinkButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 5/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemButtonStyle: ButtonStyle {
    @State private var hovering: Bool = false

    var read: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundColor(read ? Color(UIColor.systemPurple) : Color(UIColor.link))
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
