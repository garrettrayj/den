//
//  ArticleHero.swift
//  Den
//
//  Created by Garrett Johnson on 9/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct ArticleHero: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.displayScale) private var displayScale

    let url: URL
    let width: CGFloat
    let height: CGFloat

    var aspectRatio: CGFloat? {
        guard width > 0, height > 0 else { return nil }
        return width / height
    }

    static let baseSize = CGSize(width: 700, height: 400)

    private var scaledSize: CGSize {
        return CGSize(
            width: ArticleHero.baseSize.width * dynamicTypeSize.layoutScalingFactor,
            height: ArticleHero.baseSize.height * dynamicTypeSize.layoutScalingFactor
        )
    }

    private var thumbnailPixelSize: CGSize {
        CGSize(
            width: scaledSize.width * displayScale,
            height: scaledSize.height * displayScale
        )
    }

    private var adjustedItemImageSize: CGSize {
        // Small images scale with dynamic type size even though bluring is likely
        if width < scaledSize.width {
            return CGSize(
                width: width * dynamicTypeSize.layoutScalingFactor,
                height: height * dynamicTypeSize.layoutScalingFactor
            )
        }

        return CGSize(width: width, height: height)
    }

    var body: some View {
        if aspectRatio == nil {
            ImageDepression(padding: 12) {
                WebImage(
                    url: url,
                    options: [.delayPlaceholder],
                    context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                )
                .resizable()
                .placeholder { ImageErrorPlaceholder() }
                .indicator(.activity)
                .modifier(ImageBorderModifier(cornerRadius: 4))
            }
            .aspectRatio(16/9, contentMode: .fit)
        } else if width < scaledSize.width {
            ImageDepression(padding: 12) {
                WebImage(
                    url: url,
                    options: [.delayPlaceholder],
                    context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                )
                .resizable()
                .placeholder { ImageErrorPlaceholder() }
                .indicator(.activity)
                .aspectRatio(aspectRatio, contentMode: .fit)
                .frame(
                    maxWidth: adjustedItemImageSize.width > 0 ? adjustedItemImageSize.width : nil,
                    maxHeight: adjustedItemImageSize.height > 0 ? adjustedItemImageSize.height : nil
                )
                .modifier(ImageBorderModifier(cornerRadius: 4))
            }
            .scaledToFill()
        } else {
            WebImage(
                url: url,
                options: [.delayPlaceholder],
                context: [.imageThumbnailPixelSize: thumbnailPixelSize]
            )
            .resizable()
            .placeholder { ImageErrorPlaceholder() }
            .indicator(.activity)
            .aspectRatio(aspectRatio, contentMode: .fill)
            .background(.quaternary)
            .modifier(ImageBorderModifier())
        }
    }
}
