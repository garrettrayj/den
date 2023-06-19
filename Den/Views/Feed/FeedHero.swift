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
    @Environment(\.colorScheme) private var colorScheme
    
    let heroImage: URL

    var body: some View {
        VStack(spacing: 0) {
            WebImage(url: heroImage, options: [.decodeFirstFrameOnly, .delayPlaceholder])
                .resizable()
                .placeholder { ImageErrorPlaceholder() }
                .indicator(.activity)
                .scaledToFit()
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
                .padding()
        }
        .aspectRatio(16/9, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: 204)
        .background(.thinMaterial)
        .background {
            WebImage(url: heroImage, options: [.decodeFirstFrameOnly])
                .resizable()
                .scaledToFill()
                .background(colorScheme == .dark ? .black : .white)
        }
        .clipped()
    }
}
