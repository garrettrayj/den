//
//  ToolbarItemHoverModifier.swift
//  Den
//
//  Created by Garrett Johnson on 1/29/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ToolbarItemHoverModifier: ViewModifier {
    @State var isHovering: Bool = false

    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                isHovering = hovering
            }
            .background(isHovering ? Color.red : Color.blue)
            .cornerRadius(8)

    }
}
