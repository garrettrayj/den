//
//  Favicon.swift
//  Den
//
//  Created by Garrett Johnson on 1/6/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct Favicon<Placeholder: View>: View {
    @Environment(\.displayScale) private var displayScale
    @Environment(\.imageScale) private var imageScale
    
    let url: URL?
    
    @ViewBuilder var placeholder: Placeholder
    
    @ScaledMetric private var smallSize = 12
    @ScaledMetric private var mediumSize = 16
    @ScaledMetric private var largeSize = 20
    
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
    }

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
}
