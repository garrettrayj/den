//
//  ToolbarItemOffsetModifier.swift
//  Den
//
//  Created by Garrett Johnson on 2/20/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ToolbarItemOffsetModifier: ViewModifier {
    var alignment: Edge.Set = .trailing
    var distance: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .padding(alignment, alignment == .leading ? -8 : 8)
    }
}
