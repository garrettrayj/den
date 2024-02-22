//
//  Favicon.swift
//  Den
//
//  Created by Garrett Johnson on 1/6/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

import SDWebImageSwiftUI

struct Favicon<Placeholder: View>: View {
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlActiveState
    #endif
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.faviconSize) private var faviconSize
    @Environment(\.faviconPixelSize) private var faviconPixelSize
    
    let url: URL?
    
    @ViewBuilder var placeholder: Placeholder

    private var opacity: CGFloat {
        #if os(macOS)
        if controlActiveState == .inactive || !isEnabled {
            return 0.4
        } else {
            return 1
        }
        #else
        if !isEnabled {
            return 0.4
        } else {
            return 1
        }
        #endif
    }
    
    var body: some View {
        WebImage(
            url: url,
            options: [.decodeFirstFrameOnly, .delayPlaceholder],
            context: [.imageThumbnailPixelSize: faviconPixelSize]
        ) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            placeholder
        }
        .frame(width: faviconSize.width, height: faviconSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .opacity(opacity)
    }
}
