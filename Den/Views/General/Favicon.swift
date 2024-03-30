//
//  Favicon.swift
//  Den
//
//  Created by Garrett Johnson on 1/6/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct Favicon<Placeholder: View>: View {
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlActiveState
    #endif
    @Environment(\.displayScale) private var displayScale
    @Environment(\.imageScale) private var imageScale
    @Environment(\.isEnabled) private var isEnabled
    
    let url: URL?
    
    @ViewBuilder var placeholder: Placeholder
    
    @ScaledMetric private var smallSize = 12
    @ScaledMetric private var mediumSize = 16
    @ScaledMetric private var largeSize = 20

    private var size: CGFloat {
        switch imageScale {
        case .small:
            smallSize
        case .medium:
            mediumSize
        case .large:
            largeSize
        @unknown default:
            mediumSize
        }
    }
    
    private var thumbnailPixelSize: CGSize {
        CGSize(width: size * displayScale, height: size * displayScale)
    }
    
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
            context: [.imageThumbnailPixelSize: thumbnailPixelSize]
        ) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            placeholder
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .opacity(opacity)
    }
}
