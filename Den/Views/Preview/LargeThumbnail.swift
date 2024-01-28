//
//  LargeThumbnail.swift
//  Den
//
//  Created by Garrett Johnson on 8/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

import SDWebImageSwiftUI

struct LargeThumbnail: View {
    @Environment(\.largeThumbnailSize) private var largeThumbnailSize
    @Environment(\.largeThumbnailPixelSize) private var largeThumbnailPixelSize

    let url: URL
    let isRead: Bool

    let width: CGFloat?
    let height: CGFloat?

    var body: some View {
        if let aspectRatio = aspectRatio {
            if aspectRatio < 1/2 || width! < largeThumbnailSize.width {
                ImageDepression(padding: 8) {
                    webImage
                        .scaledToFit()
                        .modifier(ImageBorderModifier(cornerRadius: 4))
                        .frame(maxWidth: width!, maxHeight: height!)
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
            let width = width,
            let height = height,
            width > 0,
            height > 0
        else { return nil }

        return width / height
    }
    
    private var webImage: some View {
        WebImage(
            url: url,
            context: [.imageThumbnailPixelSize: largeThumbnailPixelSize]
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
