//
//  PreviewImageView.swift
//  Den
//
//  Created by Garrett Johnson on 8/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct PreviewImageView: View {
    let item: Item

    var body: some View {
        WebImage(url: item.image, context: [.imageThumbnailPixelSize: ImageReferenceSize.preview])
            .resizable()
            .placeholder { ItemImagePlaceholderView(imageURL: item.image, aspectRatio: item.imageAspectRatio) }
            .aspectRatio(item.imageAspectRatio, contentMode: .fit)
            .frame(
                maxWidth: item.imageWidth > 0 ? CGFloat(item.imageWidth) : nil,
                maxHeight: item.imageHeight > 0 ? CGFloat(item.imageHeight) : nil
            )
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1)
            )
            .accessibility(label: Text("Preview Image"))
    }
}
