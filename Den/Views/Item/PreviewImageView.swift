//
//  PreviewImageView.swift
//  Den
//
//  Created by Garrett Johnson on 8/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PreviewImageView: View {
    let item: Item

    var body: some View {
        Group {
            if item.imageAspectRatio == nil {
                VStack {
                    AsyncImage(url: item.image) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(4)
                    } placeholder: {
                        ItemImagePlaceholderView(imageURL: item.image, aspectRatio: 2)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(16/9, contentMode: .fill)
                .padding(8)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .cornerRadius(6)
            } else {
                AsyncImage(url: item.image) { image in
                    image
                        .resizable()
                        .aspectRatio(item.imageAspectRatio, contentMode: .fit)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1)
                        )
                } placeholder: {
                    ItemImagePlaceholderView(imageURL: item.image, aspectRatio: item.imageAspectRatio, padding: 8)
                }
                .frame(
                    maxWidth: item.imageWidth > 0 ? CGFloat(item.imageWidth) : nil,
                    maxHeight: item.imageHeight > 0 ? CGFloat(item.imageHeight) : nil
                )
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .cornerRadius(6)
            }
        }
        .accessibility(label: Text("Preview image"))
    }
}
