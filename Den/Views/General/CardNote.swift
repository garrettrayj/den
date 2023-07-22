//
//  CardNote.swift
//  Den
//
//  Created by Garrett Johnson on 7/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct CardNote<CaptionContent: View, IconContent: View>: View {
    @Environment(\.isEnabled) private var isEnabled

    let title: Text
    var caption: CaptionContent?
    var icon: IconContent?
    
    init(
        _ title: Text,
        caption: @escaping () -> CaptionContent?,
        icon: @escaping () -> IconContent?
    ) {
        self.title = title
        self.caption = caption()
        self.icon = icon()
    }
    
    var body: some View {
        VStack(spacing: 8) {
            icon
            VStack {
                title
                caption.font(.caption)
            }
        }
        .foregroundStyle(isEnabled ? .primary : .secondary)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension CardNote where CaptionContent == Never, IconContent == Never {
    init(_ title: Text) {
        self.title = title
    }
}

extension CardNote where CaptionContent == Never {
    init(_ title: Text, icon: @escaping () -> IconContent) {
        self.title = title
        self.icon = icon()
    }
}

extension CardNote where IconContent == Never {
    init(_ title: Text, caption: @escaping () -> CaptionContent) {
        self.title = title
        self.caption = caption()
    }
}
