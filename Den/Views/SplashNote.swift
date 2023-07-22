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

struct SplashNote<CaptionContent: View, HatContent: View>: View {
    @Environment(\.isEnabled) private var isEnabled

    let title: Text
    var caption: CaptionContent?
    var hat: HatContent?
    
    init(
        _ title: Text,
        caption: @escaping () -> CaptionContent?,
        hat: @escaping () -> HatContent?
    ) {
        self.title = title
        self.caption = caption()
        self.hat = hat()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            hat.imageScale(.large)
            title.font(.title)
            caption
            Spacer()
        }
        .multilineTextAlignment(.center)
        .foregroundColor(isEnabled ? .primary : .secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

extension SplashNote where CaptionContent == Never, HatContent == Never {
    init(_ title: Text) {
        self.title = title
    }
}

extension SplashNote where CaptionContent == Never {
    init(_ title: Text, hat: @escaping () -> HatContent) {
        self.title = title
        self.hat = hat()
    }
}

extension SplashNote where HatContent == Never {
    init(_ title: Text, caption: @escaping () -> CaptionContent) {
        self.title = title
        self.caption = caption()
    }
}
