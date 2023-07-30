//
//  SplashNote.swift
//  Den
//
//  Created by Garrett Johnson on 1/9/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SplashNote<CaptionContent: View, IconContent: View>: View {
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
        VStack(spacing: 16) {
            Spacer()
            icon.imageScale(.large)
            title.font(.title)
            caption
            Spacer()
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(isEnabled ? .primary : .secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}

extension SplashNote where CaptionContent == Never, IconContent == Never {
    init(_ title: Text) {
        self.title = title
    }
}

extension SplashNote where CaptionContent == Never {
    init(_ title: Text, icon: @escaping () -> IconContent) {
        self.title = title
        self.icon = icon()
    }
}

extension SplashNote where IconContent == Never {
    init(_ title: Text, caption: @escaping () -> CaptionContent) {
        self.title = title
        self.caption = caption()
    }
}
