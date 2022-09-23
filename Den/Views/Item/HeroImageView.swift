//
//  HeroImageView.swift
//  Den
//
//  Created by Garrett Johnson on 9/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct HeroImageView: View {
    let item: Item

    var body: some View {
        AsyncImage(url: item.image) { image in
            image.resizable().aspectRatio(item.imageAspectRatio, contentMode: .fill)
        } placeholder: {
            ItemImagePlaceholderView(imageURL: item.image, aspectRatio: item.imageAspectRatio, padding: 12)
        }
        .frame(maxWidth: item.imageWidth > 0 ? CGFloat(item.imageWidth) : nil)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1)
        )
        .accessibility(label: Text("Hero image"))
    }
}
