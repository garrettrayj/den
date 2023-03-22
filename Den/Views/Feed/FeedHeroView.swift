//
//  FeedHeroView.swift
//  Den
//
//  Created by Garrett Johnson on 2/9/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedHeroView: View {
    let heroImage: URL

    var body: some View {
        VStack(spacing: 0) {
            WebImage(url: heroImage, options: [.decodeFirstFrameOnly, .delayPlaceholder])
                .resizable()
                .placeholder { ImageErrorPlaceholder() }
                .indicator(.activity)
                .scaledToFit()
                .cornerRadius(8)
                .shadow(radius: 3, x: 1, y: 2)
                .padding()
        }
        .aspectRatio(16/9, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: 240)
        .background(.thinMaterial)
        .background {
            WebImage(url: heroImage, options: [.decodeFirstFrameOnly])
                .resizable()
                .scaledToFill()
                .background(Color(.secondarySystemGroupedBackground))

        }
        .clipped()
    }
}
