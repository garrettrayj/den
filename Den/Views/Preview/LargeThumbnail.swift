//
//  LargeThumbnail.swift
//  Den
//
//  Created by Garrett Johnson on 8/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct LargeThumbnail: View {
    @Environment(\.displayScale) private var displayScale
    
    let url: URL
    let isRead: Bool

    let sourceWidth: CGFloat?
    let sourceHeight: CGFloat?
    
    @ScaledMetric private var thumbnailWidth = 300
    @ScaledMetric private var thumbnailHeight = 900
    
    var body: some View {
        if let aspectRatio = aspectRatio {
            if aspectRatio < 1/3 || sourceWidth! < thumbnailWidth {
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
            ZStack {
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(16/9, contentMode: .fit)
            .background(alignment: .center) {
                webImage.scaledToFill()
            }
            .modifier(ImageBorderModifier(cornerRadius: 6))
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
            context: [
                .imageThumbnailPixelSize: CGSize(
                    width: thumbnailWidth * displayScale,
                    height: thumbnailHeight * displayScale
                )
            ]
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
