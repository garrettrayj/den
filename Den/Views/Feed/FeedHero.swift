//
//  FeedHero.swift
//  Den
//
//  Created by Garrett Johnson on 2/9/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedHero: View {
    let url: URL

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            WebImage(url: url, options: [.decodeFirstFrameOnly, .delayPlaceholder])
                .resizable()
                .placeholder { ImageErrorPlaceholder() }
                .indicator(.activity)
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
                .padding(.vertical)
                .padding(.horizontal, 8)
            Spacer()
        }
        .aspectRatio(16/9, contentMode: .fit)
        .frame(maxHeight: 200)
        .background {
            WebImage(url: url, options: [.decodeFirstFrameOnly])
                .resizable()
                .scaledToFill()
                .background(.background)
                .overlay(.thinMaterial)
        }
        .clipped()
    }
}
