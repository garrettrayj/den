//
//  HeroImageView.swift
//  Den
//
//  Created by Garrett Johnson on 9/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct HeroImageView: View {
    let item: Item

    var body: some View {
        Group {
            if item.imageAspectRatio == nil {
                VStack {
                    WebImage(url: item.image, context: [.imageThumbnailPixelSize: ImageReferenceSize.full])
                        .resizable()
                        .purgeable(true)
                        .placeholder {
                            ItemImagePlaceholderView()
                        }
                        .scaledToFit()
                        .cornerRadius(4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(16/9, contentMode: .fill)
                .padding(8)
            } else if CGFloat(item.imageWidth) < ImageSize.full.width {
                VStack {
                    WebImage(url: item.image, context: [.imageThumbnailPixelSize: ImageReferenceSize.full])
                        .resizable()
                        .purgeable(true)
                        .placeholder {
                            ItemImagePlaceholderView()
                        }
                        .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                        .cornerRadius(4)
                        .frame(
                            maxWidth: item.imageWidth > 0 ? CGFloat(item.imageWidth) : nil,
                            maxHeight: item.imageHeight > 0 ? CGFloat(item.imageHeight) : nil
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(8)
            } else {
                WebImage(url: item.image, context: [.imageThumbnailPixelSize: ImageReferenceSize.full])
                    .resizable()
                    .purgeable(true)
                    .placeholder {
                        ItemImagePlaceholderView()
                    }
                    .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1)
                    )
            }
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(6)
        .accessibility(label: Text("Hero image"))
    }
}
