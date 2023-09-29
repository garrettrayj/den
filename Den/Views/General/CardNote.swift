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
        HStack {
            Spacer(minLength: 0)
            VStack(spacing: 8) {
                icon.foregroundStyle(.tertiary).fontWeight(.bold).imageScale(.large)
                VStack {
                    title.fontWeight(.medium)
                    caption.font(.caption)
                }.foregroundStyle(.secondary)
            }
            .padding()
            Spacer(minLength: 0)
        }
        .background(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: 8,
                    bottomTrailing: 8,
                    topTrailing: 0
                )
            )
            #if os(macOS)
            .fill(.background.quinary)
            #else
            .fill(Color(.secondarySystemGroupedBackground))
            #endif
            .strokeBorder(.separator)
            .padding(.top, -1)
        )
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
