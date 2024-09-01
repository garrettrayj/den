//
//  SmallThumbnail.swift
//  Den
//
//  Created by Garrett Johnson on 4/17/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct SmallThumbnail: View {
    @Environment(\.displayScale) private var displayScale
    
    let url: URL
    let isRead: Bool
    
    @ScaledMetric private var size = 80
    
    private var thumbnailPixelSize: CGSize {
        CGSize(width: size * displayScale, height: size * displayScale)
    }

    var body: some View {
        WebImage(
            url: url,
            options: [.decodeFirstFrameOnly],
            context: [.imageThumbnailPixelSize: thumbnailPixelSize]
        ) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            ImageErrorPlaceholder()
        }
        .modifier(PreviewImageStateModifier(isRead: isRead))
        .frame(width: size, height: size)
        .background(.fill.tertiary)
        .modifier(ImageBorderModifier(cornerRadius: 6))
    }
}
