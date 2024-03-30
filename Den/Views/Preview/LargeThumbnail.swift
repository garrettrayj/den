//
//  LargeThumbnail.swift
//  Den
//
//  Created by Garrett Johnson on 8/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct LargeThumbnail: View {
    @Environment(\.displayScale) private var displayScale
    
    let url: URL
    let isRead: Bool

    let sourceWidth: CGFloat?
    let sourceHeight: CGFloat?
    
    @ScaledMetric private var thumbnailWidth = 384
    @ScaledMetric private var thumbnailHeight = 768
    
    private var thumbnailPixelSize: CGSize {
        CGSize(width: thumbnailWidth * displayScale, height: thumbnailHeight * displayScale)
    }

    var body: some View {
        if let aspectRatio = aspectRatio {
            if aspectRatio < 1/2 || sourceWidth! < thumbnailWidth {
                ImageDepression(padding: 8) {
                    webImage
                        .scaledToFit()
                        .modifier(ImageBorderModifier(cornerRadius: 4))
                        .frame(maxWidth: sourceWidth!, maxHeight: sourceHeight!)
                }
                .aspectRatio(16/9, contentMode: .fit)
            } else {
                webImage
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .background(.fill.tertiary)
                    .modifier(ImageBorderModifier(cornerRadius: 6))
            }
        } else {
            ImageDepression(padding: 8) {
                webImage
                    .scaledToFit()
                    .modifier(ImageBorderModifier(cornerRadius: 4))
            }
            .aspectRatio(16/9, contentMode: .fit)
        }
    }
    
    private var aspectRatio: CGFloat? {
        guard
            let width = sourceWidth,
            let height = sourceHeight,
            width > 0,
            height > 0
        else { return nil }

        return width / height
    }
    
    private var webImage: some View {
        WebImage(
            url: url,
            context: [.imageThumbnailPixelSize: thumbnailPixelSize]
        ) { image in
            image
        } placeholder: {
            ImageErrorPlaceholder()
        }
        .purgeable(true)
        .resizable()
        .modifier(PreviewImageStateModifier(isRead: isRead))
    }
}
