//
//  FeedTitleButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedTitleButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundStyle(isEnabled ? .primary : .secondary)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .modifier(HoverHighlightModifier())
    }
}
