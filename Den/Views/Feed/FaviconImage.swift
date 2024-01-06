//
//  SmallFavicon.swift
//  Den
//
//  Created by Garrett Johnson on 1/6/24.
//  Copyright © 2024 Garrett Johnson
//

import SwiftUI

import SDWebImageSwiftUI

enum FaviconSize {
    case small
    case medium
    case large
}

struct FaviconImage: View {
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlActiveState
    #endif
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.smallFaviconSize) private var smallFaviconSize
    @Environment(\.smallFaviconPixelSize) private var smallFaviconPixelSize
    @Environment(\.mediumFaviconSize) private var mediumFaviconSize
    @Environment(\.mediumFaviconPixelSize) private var mediumFaviconPixelSize
    @Environment(\.largeFaviconSize) private var largeFaviconSize
    @Environment(\.largeFaviconPixelSize) private var largeFaviconPixelSize

    var url: URL?
    var size: FaviconSize

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
    
    var imageSize: CGSize {
        switch size {
        case .small:
            return smallFaviconSize
        case .medium:
            return mediumFaviconSize
        case .large:
            return largeFaviconSize
        }
    }
    
    var pixelSize: CGSize {
        switch size {
        case .small:
            return smallFaviconPixelSize
        case .medium:
            return mediumFaviconPixelSize
        case .large:
            return largeFaviconPixelSize
        }
    }
    
    var body: some View {
        WebImage(
            url: url,
            options: [.decodeFirstFrameOnly, .delayPlaceholder],
            context: [.imageThumbnailPixelSize: pixelSize]
        ) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            Image(systemName: "dot.radiowaves.up.forward").foregroundStyle(.primary)
        }
        .frame(width: imageSize.width, height: imageSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .opacity(opacity)
    }
}
