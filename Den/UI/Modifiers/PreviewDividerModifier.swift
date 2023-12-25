//
//  PreviewDividerModifier.swift
//  Den
//
//  Created by Garrett Johnson on 12/24/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct PreviewDividerModifier: ViewModifier {
    let showDivider: Bool

    func body(content: Content) -> some View {
        if showDivider {
            content
        } else {
            content
                .padding(.bottom, 1)
                .overlay(Divider().opacity(0.75), alignment: .bottom)
        }
    }
}
