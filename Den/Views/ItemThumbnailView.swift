//
//  ItemThumbnailView.swift
//  Den
//
//  Created by Garrett Johnson on 4/17/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

import Kingfisher

struct ItemThumbnailView: View {
    @ObservedObject var item: Item

    var body: some View {
        KFImage(item.image)
            .placeholder({ _ in
                Image(systemName: "photo")
                    .foregroundColor(Color(UIColor.tertiaryLabel))
            })
            .resizing(referenceSize: ImageSize.thumbnail, mode: .aspectFill)
            .scaleFactor(UIScreen.main.scale)
            .fade(duration: 0.3)
            .frame(width: ImageSize.thumbnail.width, height: ImageSize.thumbnail.height)
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4).stroke(Color(UIColor.opaqueSeparator), lineWidth: 1)
            )
            .accessibility(label: Text("Thumbnail Image"))
            .opacity(item.read ? 0.65 : 1.0)
    }
}
